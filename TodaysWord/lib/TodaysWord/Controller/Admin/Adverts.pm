package TodaysWord::Controller::Admin::Adverts;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use TodaysWord::Form::Advert;

=head1 NAME

TodaysWord::Controller::Admin::Adverts - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub all :Local {
    my ( $self, $c) = @_;

    # adverts.status: 1: running, 0: deleted, 2: off

    my $status = $TodaysWord::Setup::ADVERT_RUNNING;
    if($c->req->param('status')){
       $status = $c->req->param('status');
    }

    my @adverts;
    if($c->req->param('orderby')){
       @adverts = $c->model('DB')->resultset('Advert')->search({
            status => { '=', $status },
            order_by => { -desc => [$c->req->param('orderby')] }
       });
    }else{
       @adverts = $c->model('DB')->resultset('Advert')->search({
            status => { '=', $status },
       });
    }
    foreach my $advert (@adverts) {
       my @ad_impressions = $advert->ad_impressions();

       $advert->{'total_impressions'} = scalar(@ad_impressions);
    }

    $c->stash(template => 'admin/adverts/adverts.tt', adverts => \@adverts);
}

=head2 show

=cut

sub show :Local {
    my ( $self, $c, $advert_id) = @_;

    # adverts.status: 1: running, 0: deleted, 2: off

    my $advert = $c->model('DB')->resultset('Advert')->find({
            id => { '=', $advert_id }
      });

    $c->stash(template => 'admin/adverts/advert.tt', advert => $advert);
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

   my $form = TodaysWord::Form::Advert->new;

   my $advert;
   my $error_message = "";
   if($c->request->params->{'code'}){

      my $valid = 1;
      # Validate the input
      if($valid){
         my $time = time();
         $advert = $c->model('DB::Advert')->find_or_create({
                                    source => $c->req->param('source'),
                                    code => $c->req->param('code'),
                                    width => $c->req->param('width'),
                                    height => $c->req->param('height'),
                                    create_date => $time
                    });



         # Redirect the user back to the list page
         $c->response->redirect("/admin/adverts/show/" . $advert->id);

      }else{
         $error_message = "Missing fields!";
         $c->stash( template => 'admin/adverts/add_advert.tt', form => $form, error_message => $error_message );
      }
   }else{
      # Set the template
      $c->stash( template => 'admin/adverts/add_advert.tt', form => $form, error_message => $error_message );
   }
}


=head2 edit

Process the FormHandler crossword form

=cut

sub edit {
   my ( $self, $c, $advert_id ) = @_;

   my $advert;
   my $error_message = "";
   if($c->request->params->{'code'}){

      my $valid = 1;
      # Validate the input
      if($valid){
         my $time = time();
         $advert = $c->model('DB::Advert')->find({ id => $advert_id });

         if($c->req->param('source') ne $advert->source){
            $advert->update('source', $c->req->param('source'));
         }
         if($c->req->param('code') ne $advert->code){
            $advert->update('code', $c->req->param('code'));
         }
         if($c->req->param('width') ne $advert->width){
            $advert->update('width', $c->req->param('width'));
         }
         if($c->req->param('height') ne $advert->height){
            $advert->update('height', $c->req->param('height'));
         }
         if($c->req->param('status') ne $advert->status){
            $advert->update('status', $c->req->param('status'));
         }

         # Redirect the user back to the list page
         $c->response->redirect("/admin/adverts/show/" . $advert->id);

      }else{
         $error_message = "Missing fields!";
         $c->stash( template => 'admin/adverts/add_advert.tt', error_message => $error_message );
      }
   }else{
      # Set the template
      $c->stash( template => 'admin/adverts/add_advert.tt', error_message => $error_message );
   }
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

