package TodaysWord::Controller::Games::Sudoku;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

TodaysWord::Controller::Games::Sudoku - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash( template => 'games/sudoku/sudokus.tt', sudokus => [$c->model('DB')->resultset('Sudoku')->all]);
}


=head2 play

=cut

sub play :Local {
    my ($self, $c, $id) = @_;

    # TODO - Insert the game_play entry
    #      - Split out the timing from the game play game_timer
    # TODO - Calculate timer with taking into account that people can refresh the page,
    #        which could mess up the timer. If anything, cause a refresh to give a penalty
    #        Perhaps send the timer time passed thus far

    my $sudoku = $c->model('DB::Sudoku')->find({id => $id});
    my @cells = $c->model('DB::SudokuCell')->search(
         {sudoku_id => $sudoku->id},
         {order_by => 'y, x' });

    # Insert the game_play entry
    my $user_id;
    my $ip = $c->request->address;
    if($c->user_exists){
       $user_id = $c->user->id;
    }
    my $start_time = time();

    # TODO - Check if there is a game_play started already for this game
    #        Specially if this is a prize elegible game
    my $is_daily_game = 1;


    my $game_play = $c->model('DB::GamePlay')->find_or_create({
                                             game_table => 'sudoku',
                                             game_id => $id,
                                             user_id => $user_id,
                                             ip => $ip,
                                             start_time => $start_time
                                      });
    # Start the timer
    my $game_timer = $c->model('DB::GameTimer')->create({
                                             game_play_id => $game_play->id,
                                             start_time => $start_time
                                      });
    my $timer_start = "00:00:00";

    $c->stash( template => 'games/sudoku/sudoku.tt', sudoku => $sudoku, cells => \@cells, game_play => $game_play, timer_start => $timer_start);
}

=head2 pause

=cut

sub pause :Local {
    my ($self, $c, $game_play_id) = @_;

    $c->log->debug("pause sudoku game play id: $game_play_id");

    # Put in an end timer
    my @game_timers = $c->model('DB::GameTimer')->search({game_play_id => $game_play_id});
    $game_timers[$#game_timers]->update({end_time => time()});

    my $game_play = $c->model('DB::GamePlay')->find({id => $game_play_id});
    $c->stash( template => 'games/sudoku/pause_sudoku.tt', game_play => $game_play);
}

=head2 pause

=cut

sub resume :Local {
    my ($self, $c, $game_play_id) = @_;

    # Save the start, pause and resume times in game_timer
    my $game_timer = $c->model('DB::GameTimer')->create({
                                             game_play_id => $game_play_id,
                                             start_time => time()
                                      });

    $c->stash( template => 'games/sudoku/resume_sudoku.tt');
}
=head2 play

=cut

sub done :Local {
    my ($self, $c, $game_play_id) = @_;

    # Stop the clock
    my @game_timers = $c->model('DB::GameTimer')->find({game_play_id => $game_play_id});
    my $end_time = time();
    $game_timers[$#game_timers]->update({end_time => $end_time});

    my $time_played = 0;
    foreach my $game_timer(@game_timers) {
       if($game_timer->end_time){
          $time_played += ($game_timer->end_time - $game_timer->start_time);
       }else{
          $time_played += ($end_time - $game_timer->start_time);
       }
    }

    my %SubmittedBoard;
    foreach my $k($c->req->param()) {

       if($k =~ m/x(\d+)y(\d+)/){

          my $x = $1;
          my $y = $2;
          $SubmittedBoard{$y}{$x} = $c->req->param($k);

       }
    }

    my $game_play = $c->model('DB::GamePlay')->find({id => $game_play_id});

    # Get the answer key
    my $sudoku = $c->model('DB::Sudoku')->find({id => $game_play->game_id});
    my @cells = $c->model('DB::SudokuCell')->search({sudoku_id => $sudoku->id});

    my %AnswerBoard;
    foreach my $cell(@cells) {
       if($cell->hint){
          $AnswerBoard{$cell->y}{$cell->x}->{'hint'} = 1;
       }
       $AnswerBoard{$cell->y}{$cell->x}->{'solution'} = $cell->solution;
    }


    # Sudoku scoring: http://dkmgames.blogspot.com/2010/01/sudoku-scoring-system.html
    my $x; my $y;
    my $count = 0;
    my @ResultCells;
    my $score = 0;
    foreach $y(sort{$a <=> $b} keys %AnswerBoard) {
       foreach my $x(sort{$a <=> $b} keys %{$AnswerBoard{$y}}) {

          my %result;
          $result{'x'} = $x;
          $result{'y'} = $y;
          $result{'solution'} = $AnswerBoard{$y}{$x}->{'solution'};
          $result{'answer'} = $SubmittedBoard{$y}{$x};

          if($AnswerBoard{$y}{$x}->{'solution'}){
             $c->log->debug("==? " . $SubmittedBoard{$y}{$x} ." : ". $AnswerBoard{$y}{$x}->{'solution'});
             if($SubmittedBoard{$y}{$x} == $AnswerBoard{$y}{$x}->{'solution'}){
                $result{'class'} = 'correct';
                $score += 10;
             }elsif($AnswerBoard{$y}{$x}->{'hint'}){
                $result{'class'} = 'hint';
                $result{'hint'} = 1;
             }else{
                $c->log->debug("NO! " . ($SubmittedBoard{$y}{$x} == $AnswerBoard{$y}{$x}->{'solution'}));
                $result{'class'} = 'incorrect';
             }
             $c->log->debug("resulting class: " . $result{'class'});
             if(! $SubmittedBoard{$y}{$x}){
                $result{'class'} = 'blank';
                $score -= 5;
             }
             $result{'submission'} = $SubmittedBoard{$y}{$x};
          }


          $c->log->debug("**** $count -> x: $result{x} ($x), y: $result{y} ($y) => $result{submission} : $result{class}");
          $ResultCells[$count] = \%result;
          $count++;
       }
    }

    $c->stash( template => 'games/sudoku/done_sudoku.tt', sudoku => $sudoku, cells => \@ResultCells,
               score => $score, time_played => $time_played);
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

