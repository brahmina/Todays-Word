package TodaysWord::Controller::Admin::WordGamesToday;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use TodaysWord::Model::Category;


=head1 NAME

TodaysWord::Controller::Admin::WordGamesToday - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path {
    my ( $self, $c) = @_;

    #my $games = TodaysWord::Model::Playnow->get_all_p($c);

    $c->stash(template => 'admin/wordgamestoday/index.tt');
}


=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

