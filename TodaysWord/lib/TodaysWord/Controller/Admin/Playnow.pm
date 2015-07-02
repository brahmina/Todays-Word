package TodaysWord::Controller::Admin::Playnow;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use TodaysWord::Form::Playnow;
use TodaysWord::Utilities::Drawing;
use TodaysWord::Model::Category;
use TodaysWord::Utilities::Strings;

=head1 NAME

TodaysWord::Controller::Admin::Playnow - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path {
    my ( $self, $c) = @_;

    my $games = TodaysWord::Model::Playnow->get_all_games($c, order_by_releasable => 1);

    $c->stash(template => 'admin/playnow/index.tt', games => $games);
}

=head2 add

=cut

sub add :Local {
    my ( $self, $c ) = @_;

    my ($id, $form) = $self->form($c, undef);

    if($id){
       # Redirect the user back to the list page
       $c->response->redirect("/admin/playnow/edit/$id");
    }else{
       $c->stash( template => "admin/playnow/add.tt" );
    }
}

=head2 toggle_releasable

=cut

sub toggle_releasable :Local :Args(1) {
    my ( $self, $c, $playnow_id ) = @_;

    $c->log->debug("in toggle_releasable");

    my $playnow = $c->model('DB')->resultset('Playnow')->find({
         id => { '=', $playnow_id } 
    });

    if($playnow->releasable){
       $playnow->update({'releasable', 0});
    }else{
       $playnow->update({'releasable', 1});
    }

    $c->stash( template => "blank.tt" );
}

=head2 edit

=cut

sub edit :Local :Args(1) {
    my ( $self, $c, $playnow_id ) = @_;

    my $playnow = $c->model('DB')->resultset('Playnow')->find({
         id => { '=', $playnow_id } 
    });

    my ($id, $form) = $self->form($c, $playnow);
    $c->stash( form => $form );

    my $custom_submit = $form->custom_submit();
    $custom_submit =~ s/Add/Edit/g;
    $custom_submit =~ s/add/edit/g;
    $form->custom_submit($custom_submit);
    $form->field('which')->value('edit'); 
    
    # Init categories
    TodaysWord::Model::Category->init_associate_categories($c, table => 'playnow', table_id => $playnow_id);

    # Init keywords
    TodaysWord::Model::Keyword->init_associate_keywords($c, table => 'playnow', table_id => $playnow_id, item => $playnow);
    
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

         my $code = $c->req->param('code');
         my ($width, $height) = TodaysWord::Model::Playnow->get_dimensions_from_code($c, $code);
         if($code !~ m/<embed wmode="transparent"/){
            $code =~ s/<embed/<embed wmode="transparent" /;
            $code =~ s/<\/embed>/<param name="wmode" value="transparent" \/><\/param><\/embed>/;
         }

         $game = $c->model('DB::Playnow')->find_or_create({
                                    game => $c->req->param('game'),
                                    name => $c->req->param('name'),
                                    seo_name => TodaysWord::Utilities::Strings::getSEO($c->req->param('name')),
                                    code => $c->req->param('code'),
                                    meta_description => $c->req->param('meta_description'),
                                    width => $width,
                                    height => $height,
                                    blurb => $c->req->param('blurb'),
                                    description => $c->req->param('description'),
                                    source => $c->req->param('source'),
                                    sort_order => $sort_order
                    });
           return ($game->id, $form);
      }else{
         $error_message = "Missing fields!";
         $c->stash( form => $form, error_message => $error_message );
         return (0, $form);
      }
   }elsif($c->request->params->{'which'} && $c->request->params->{'which'} eq "edit"){
      my $valid = 1;
      # Validate the input
      if($valid){
         my @fields = ("game", "name", "code", "meta_description", "blurb", "description", "source");
         foreach my $field (@fields) {

            $c->log->debug("field: $field");
            $c->log->debug("param: ".$c->request->params->{$field});
            $c->log->debug("attribute: ".$playnow->$field);


            if($c->request->params->{$field} ne $playnow->$field){
               $playnow->update({$field => $c->request->params->{$field}});

               if($field eq "name"){
                  $playnow->update({'seo_name' => TodaysWord::Utilities::Strings::getSEO($c->req->param('name'))});
               }
            }

            if($field eq "code"){
               my ($width, $height) = TodaysWord::Model::Playnow->get_dimensions_from_code($c, $c->req->param('code'));
               $playnow->update({'width' => $width});
               $playnow->update({'height' => $height});
            }

            my $code = $c->req->param('code');
            if($code !~ m/<embed wmode="transparent"/){
               $code =~ s/<embed/<embed wmode="transparent" /;
               $code =~ s/<\/embed>/<param name="wmode" value="transparent" \/><\/param><\/embed>/;
               $playnow->update({'code' => $code});
            }
         }
         $form = TodaysWord::Form::Playnow->new(init_object => $playnow);
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

=head2 reset_order_by_rating

=cut

sub reset_order_by_rating :Local {
    my ( $self, $c ) = @_;

    my $games = TodaysWord::Model::Playnow->get_all_games($c);

    my $order = scalar(@{$games});
    foreach my $game(sort{ $a->rating <=> $b->rating || $a->rating_count <=> $b->rating_count} @{$games}) {
       if($game->sort_order != $order){
          $c->log->debug("updating sort order ".$game->id ." with $order");
          $game->update({sort_order => $order});
       }
       $order--;
    }

    $c->response->redirect("/admin/playnow/reorder");
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

=head2 sort_by

=cut

sub sort_by :Local :Args(1) {
    my ( $self, $c, $sort_by ) = @_;

    
    my $sort; my $order_by;
    if($sort_by eq "alphabetical"){
       $sort = sub {
                  $a->name cmp $b->name; 
               };
    }elsif($sort_by eq "ratings"){
       $sort = sub {
                  $a->rating <=> $b->rating || $a->rating_count <=> $b->rating_count; 
               };
    }

    my @games = $c->model('DB')->resultset('Playnow')->search(
                    {status => { '>', 0 } } );

    my $order = 1;
    foreach my $game(sort{$sort} @games) {
       if($game->sort_order != $order){
          $c->log->debug("updating sort order ".$game->id." with $order");
          $game->update({sort_order => $order});
          $order++;
       }       
    }

    # Do I have to send something?
    $c->stash( template => 'blank.tt' );
}

=head2 prep

=cut

sub prep :Local {
    my ( $self, $c ) = @_;

    $c->stash( template => 'admin/playnow/prep.tt' );
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

