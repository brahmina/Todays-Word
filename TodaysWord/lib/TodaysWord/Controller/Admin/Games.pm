package TodaysWord::Controller::Admin::Games;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

TodaysWord::Controller::Admin::Games - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub all :Local {
    my ( $self, $c) = @_;

    my @crosswords = $c->model('DB')->resultset('Crossword')->search({
         scheduled_date => { '=', undef }
    });
    my @sudokus = $c->model('DB')->resultset('Sudoku')->search({
         scheduled_date => { '=', undef }
    });

    my ($sec,$min,$hour,$mday,$month,$year,$wday,$yday,$isdst) = localtime(time);
    $self->stash_calendar($c, $month+1, $year+1900);

    $c->stash(template => 'admin/games.tt', crossword => \@crosswords, sudokus => \@sudokus);
}


=head2 index

=cut

sub index :Path :Args(2) {
    my ( $self, $c, $month, $year ) = @_;


    $c->log->debug("month: $month, year: $year");

    my @crosswords = $c->model('DB')->resultset('Crossword')->search({
         scheduled_date => { '=', undef }
    });
    my @sudokus = $c->model('DB')->resultset('Sudoku')->search({
         scheduled_date => { '=', undef }
    });

    $self->stash_calendar($c, $month, $year);

    $c->stash(template => 'admin/games.tt', crossword => \@crosswords, sudokus => \@sudokus);
}

=head2 stash_calendar

=cut

sub stash_calendar {
    my ( $self, $c, $month, $year ) = @_;

    use TodaysWord::Utilities::DailyCalendar;
    my $DailyCalendar = new TodaysWord::Utilities::DailyCalendar();
    my $calendarHTML = $DailyCalendar->getCalendarHTML($c, $month, $year, '');

    $c->stash(calendar => $calendarHTML);
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

