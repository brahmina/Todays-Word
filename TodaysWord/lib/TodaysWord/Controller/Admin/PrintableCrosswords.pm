package TodaysWord::Controller::Admin::PrintableCrosswords;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use TodaysWord::Model::Category;


=head1 NAME

TodaysWord::Controller::Admin::PrintableCrosswords - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path {
    my ( $self, $c) = @_;

    #my $games = TodaysWord::Model::Playnow->get_all_p($c);

    $c->stash(template => 'admin/printablecrosswords/index.tt');
}

=head2 add

=cut

sub add :Local {
    my ( $self, $c ) = @_;

    my ($success, $form) = $self->form($c, undef);

    if($success){
       # Redirect the user back to the list page
       $c->response->redirect("/admin/playnow/");
    }else{
       $c->stash( template => "admin/playnow/add.tt" );
    }
}

=head2 edit

=cut

sub edit :Local :Args(1) {
    my ( $self, $c, $playnow_id ) = @_;

    my $playnow = $c->model('DB')->resultset('Playnow')->find({
         id => { '=', $playnow_id } 
    });


    my $categories = TodaysWord::Model::Category->get_playnow_categories($c, $playnow_id);

    $c->stash( categories => $categories );

    my ($success, $form) = $self->form($c, $playnow);

    if(!$success){
       my $custom_submit = $form->custom_submit();
       $custom_submit =~ s/Add/Edit/g;
       $custom_submit =~ s/add/edit/g;
       $form->custom_submit($custom_submit);
       $form->field('which')->value('edit'); 
    }

    $c->stash( template => "admin/playnow/edit.tt", game => $playnow );
}


=head2 form

Process the FormHandler crossword form

=cut

sub form {
   my ( $self, $c, $playnow ) = @_;

   my $form;
   if($playnow){
      $form = TodaysWord::Form::Playnow->new(init_object => $playnow);
   }else{
      $form = TodaysWord::Form::Playnow->new();
   }

   my $game;
   my $error_message = "";
   if($c->request->params->{'which'} && $c->request->params->{'which'} eq "add"){

      my $valid = 1;
      # Validate the input
      if($valid){
         my @games = $c->model('DB')->resultset('Playnow')->search(
             { status => { '=', 1 } }, 
             { order_by => {-asc => 'sort_order'} }
         );
         my $sort_order = $games[-1]->sort_order + 1;

         my $seo_name = lc($c->req->param('name'));
         $seo_name =~ s/ /_/g;

         my ($width, $height) = TodaysWord::Model::Playnow->get_dimensions_from_code($c, $c->req->param('code'));

         $game = $c->model('DB::Playnow')->find_or_create({
                                    game => $c->req->param('game'),
                                    name => $c->req->param('name'),
                                    seo_name => $seo_name,
                                    code => $c->req->param('code'),
                                    width => $width,
                                    height => $height,
                                    description => $c->req->param('description'),
                                    source => $c->req->param('source'),
                                    sort_order => $sort_order
                    });

         

         return (1, $form);

      }else{
         $error_message = "Missing fields!";
         $c->stash( form => $form, error_message => $error_message );
         return (0, $form);
      }
   }elsif($c->request->params->{'which'} && $c->request->params->{'which'} eq "edit"){
      my $valid = 1;
      # Validate the input
      if($valid){
         my @fields = ("game", "name", "code", "description", "source");
         foreach my $field (@fields) {

            $c->log->debug("field: $field");
            $c->log->debug("param: ".$c->request->params->{$field});
            $c->log->debug("attribute: ".$playnow->$field);


            if($c->request->params->{$field} ne $playnow->$field){
               $playnow->update({$field => $c->request->params->{$field}});

               if($field eq "name"){
                  my $seo_name = lc($c->req->param('name'));
                  $seo_name =~ s/ /_/g;
                  $playnow->update({'seo_name' => $seo_name});
               }

               if($field eq "code"){
                  my ($width, $height) = TodaysWord::Model::Playnow->get_dimensions_from_code($c, $c->req->param('code'));
                  $playnow->update({'width' => $width});
                  $playnow->update({'seo_name' => $height});
               }
            }
         }

         return (1, $form);
      }else{
         $error_message = "Missing fields!";
         $c->stash( game => $playnow, error_message => $error_message );
         return (0, $form);
      }
   }else{
      # Set the template
      $c->stash( form => $form );
      return (0, $form);
   }
}

=head2 delete

=cut

sub delete :Local :Args(1) {
    my ( $self, $c, $playnow_id) = @_;

    if($playnow_id){
       my $game = $c->model('DB')->resultset('Playnow')->find({
            id => { '=', $playnow_id } 
       });
    
       $game->update({'status' => 0});
    }

    $c->response->redirect("/admin/playnow/");
}

=head2 generate_sprite

=cut

sub generate_sprite :Local {
    my ( $self, $c ) = @_;

    my $drawer = new TodaysWord::Utilities::Drawing();
   
    $drawer->make_playnow_sprites($c);

    $c->response->redirect("/admin/playnow/");
}

=head2 reorder

=cut

sub reorder :Local {
    my ( $self, $c ) = @_;

    my $games = TodaysWord::Model::Playnow->get_all_games($c);

    $c->stash( template => 'admin/playnow/reorder.tt', games => $games );
}

=head2 sort

=cut

sub sort :Local {
    my ( $self, $c ) = @_;

    my %order; my $i = 1;
    my @orders = split(",", $c->request->params->{'ordering'});
    foreach my $id (@orders) {
       $order{$id} = $i;
       $i++;
    }

    my @games = $c->model('DB')->resultset('Playnow')->search({
         status => { '>', 0 } 
    });

    foreach my $game(@games) {
       if($game->sort_order != $order{$game->id}){
          $c->log->debug("updating sort order ".$game->id);
          $game->update({sort_order => $order{$game->id}});
       }       
    }

    # Do I have to send something?
    $c->stash( template => 'blank.tt' );
}



=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

