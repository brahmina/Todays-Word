package TodaysWord::Controller::Admin::Scripts;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use TodaysWord::Utilities::FileSystemManager;

=head1 NAME

TodaysWord::Controller::Admin::Scripts - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller for the scripts page

=head1 METHODS

=cut


=head2 index

A listing of the available scripts to run on demand

=cut

sub index :Path {
    my ( $self, $c) = @_;

    $c->log->debug("C --> ".ref($c)); #TodaysWord

    #new TodaysWord::Fault->throw(c => $c, tech_message => "Cannot open directory: $TodaysWord::Setup::PATH/static/media");

    $c->stash(template => 'admin/scripts.tt');
}

=head2 send_future_todays_words_email

=cut

sub send_future_todays_words_email :Local {
    my ( $self, $c, $advert_id) = @_;

    $c->stash(template => 'minimal_ajax_reply.tt', response => 'Failure');

    TodaysWord::Utilities::Emailer->send_future_todays_words_email($c);

    $c->stash(response => 'Success');
}

=head2 propagate_keyword_associations_from_categories_to_playnow_games

=cut

sub propagate_keyword_associations_from_categories_to_playnow_games :Local {
    my ( $self, $c, $advert_id) = @_;

    $c->stash(template => 'minimal_ajax_reply.tt', response => 'Failure');

    TodaysWord::Model::Keyword->propagate_keyword_associations_from_categories_to_playnow_games($c);

    $c->stash(response => 'Success');
}

=head2 clean_playnow_directory

=cut

sub clean_playnow_directory :Local {
    my ( $self, $c, $advert_id) = @_;

    $c->stash(template => 'minimal_ajax_reply.tt', response => 'Failure');

    TodaysWord::Utilities::FileSystemManager->clean_playnow_directory($c);

    $c->stash(response => 'Success');
}


=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

