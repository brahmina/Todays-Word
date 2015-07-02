package TodaysWord::Controller::Admin::Keywords;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use TodaysWord::Form::Import;

=head1 NAME

TodaysWord::Controller::Admin::Keywords - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index :Path {
    my ( $self, $c) = @_;

    my $json = JSON->new->allow_nonref;
    my $keywords_json_string = TodaysWord::Model::Keyword->get_keywords_json($c);

    my @imports = $c->model('DB')->resultset('Import')->search({
                     status => { '=', 1 }
    });

    my $current_import = $c->model('DB')->resultset('Import')->find({
                     default => { '=', 1 }
    });

    $c->stash(template => 'admin/keywords/index.tt', keywords => $keywords_json_string, 
               imports => \@imports, current_import => $current_import);
}

=head2 keywords

Should be ajax, but if not, same as index

=cut

sub keywords :Local  {
    my ( $self, $c, $import_id) = @_;

    $c->request->params->{i} = $import_id;
    my $json = JSON->new->allow_nonref;
    my $keywords = TodaysWord::Model::Keyword->get_keywords_json($c);
    $c->stash->{keywords} = $keywords;
    $c->forward('View::JSON');
}

=head2 add

=cut

sub add :Local {
    my ( $self, $c ) = @_;

    my $form = $self->form($c);
    return $form;
}

=head2 form

Process the FormHandler crossword form

=cut

sub form {
   my ( $self, $c ) = @_;

   my $form = TodaysWord::Form::Import->new;

   $c->log->debug("in form with file_location: " . $c->request->params->{file_location});
   my $import;
   my $error_message = "";
   if($c->request->params->{file_location}){

      my $valid = 1;
      # Validate the input
      if($valid){

         my $fileUpload = $c->req->upload('file_location');
         my $time = time();

         my $file = "admin/files/keywords/$time.xml";
         my $file_location = $c->config->{full_path}.'/'.$file;
         my $success = $fileUpload->copy_to($file_location);

         if($success){
            $import = $c->model('DB::Import')->create({
                                       name => $c->req->param('name'),
                                       which_table => 'keyword',
                                       file_location => $file,                                       
                                       create_date => $time
                       });


            # Parse the xml file and load the database with the cells

            my $id = $import->id;
            $self->process_keywords($c, $import);

            # Redirect the user back to the list page
            $c->response->redirect("/admin/keywords");
         }else{
            $error_message = "File not uploaded";
            $c->stash( template => 'admin/keywords/add.tt', form => $form, error_message => $error_message, import => $import );
         }

      }else{
         $error_message = "Missing fields!";
         $c->stash( template => 'admin/keywords/add.tt', form => $form, error_message => $error_message, import => $import );
      }
   }else{
      # Set the template
      $c->stash( template => 'admin/keywords/add.tt', form => $form, error_message => $error_message, import => $import );
   }
}

=head2 process_keywords

Process the FormHandler crossword form

=cut

sub process_keywords {
   my ( $self, $c, $import ) = @_;

   if(! $import){
      # throw fail because import failed
      return;
   }

   open CSV, $c->config->{full_path}.'/'.$import->file_location 
         || die "Cannot open file: ".$c->config->{full_path}.'/'.$import->file_location."!\n"; # throw Fault::File::Open
   my @lines = <CSV>;
   close CSV;

   my %all_keywords;
   my @all_keywords = $c->model('DB')->resultset("Keyword")->search({
                     status => { '=', 1 }
    });
   if(@all_keywords){
      foreach my $kywd(@all_keywords) {
         $all_keywords{$kywd->keyword} = $kywd;
      }
   }

   my $keyword; my $keywords = [];
   my $keyword_import; my $keyword_imports = [];
   foreach my $line(@lines) {

      $c->log->debug("line: $line");
      my @pieces = split(',', $line);
      
      if(@pieces){

         my $k = $pieces[0];
         $k =~ s/"//g;

         if($k =~ m/keyword_phrase/){
            # Its the header, skip it
            next;
         }

         if(! $all_keywords{$k}){
            $keyword = {keyword => $k,
                        demand => $pieces[1],
                        supply => $pieces[2],
                        profitability => $pieces[3],
                        pcdm => $pieces[4],
                        cpc => $pieces[5],
                        keyworth => $pieces[6]
                    };

               $c->log->debug("pushing $k");
            push(@{$keywords}, $keyword);
         }else{
            $keyword_import = { keyword_id => $all_keywords{$k}->id,
                                import_id => $import->id };
            push(@{$keyword_imports}, $keyword_import);
         }
      }
   }

   if(scalar(@{$keywords})){
      my $keyword_tbl = $c->model('DB')->resultset("Keyword");
      my $inserted_keywords = $keyword_tbl->populate($keywords);
  
      foreach my $kywd (@{$inserted_keywords}) {
   
         $keyword_import = { keyword_id => $kywd->id,
                             import_id => $import->id };
         push(@{$keyword_imports}, $keyword_import);

         # add one for the all keywords default as well
         $keyword_import = { keyword_id => $kywd->id,
                             import_id => 12 };
         push(@{$keyword_imports}, $keyword_import);
      }
   }
   if(scalar(@{$keyword_imports})){
      my $keyword_import_tbl = $c->model('DB')->resultset("KeywordImport");
      my $inserted_keyword_imports = $keyword_import_tbl->populate($keyword_imports);
   }
}

=head2 associate

No return, just do

=cut

sub associate :Local {
    my ( $self, $c ) = @_;

    if($c->req->param('k') && $c->req->param('t') && $c->req->param('i')){
       #               keyword_id             table                  
        my $assc = $c->model('DB::KeywordAssociation')->find_or_create({
                                       keyword_id => $c->req->param('k'),
                                       which_table => $c->req->param('t'),
                                       table_id => $c->req->param('i')
                       });
    }
    $c->response->body('');
}

=head2 dessociate

No return, just do

=cut

sub dessociate :Local {
    my ( $self, $c ) = @_;

    if($c->req->param('i')){
        my $assc = $c->model('DB::KeywordAssociation')->find({
                                       keyword_id => $c->req->param('k'),
                                       which_table => $c->req->param('t'),
                                       table_id => $c->req->param('i')
                       });
    	if($assc){
        	$assc->delete();
    	}
    }
    $c->response->body('');
}


=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

