package TodaysWord::Controller::Adverts;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use TodaysWord::Model::Advert;

=head1 NAME

TodaysWord::Controller::Adverts - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub get :Local {
    my ( $self, $c, $width, $height, $position) = @_;

    # adverts.status: 1: running, 0: deleted, 2: off
    my $advert = TodaysWord::Model::Advert->get_advert($c, $width, $height, $position);

    my $user_id;
    if($c->user_exists){
       $user_id = $c->user->id;
    }

    my $ad_imp = $c->model('DB::AdImpression')->find_or_create({
                                                   advert_id => $advert->id,
                                                   user_id => $user_id,
                                                   ip => $c->request->address,
                                                   date => time(),
                                                   status => 1
                    });

    $c->response->body($advert->code);
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;









