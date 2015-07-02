package TodaysWord::Model::DailyGame;

use strict;

use TodaysWord::Utilities::Date;

##################################################
sub set_play_date {
##################################################
   my ($self, $c, $date, $game_table, $game) = @_;

   # Make sure it is tomorrow or further in the future
    my $this_date_at_midnight = TodaysWord::Utilities::Date->getDayAtMidnight($c, $date);
    if(! $this_date_at_midnight){
       $date = "Invalid date!";
    }elsif($this_date_at_midnight < time()){
       $date = "Must be in the future!";
    }else{
       my $daily_game = $c->model('DB')->resultset('DailyGame')->search({
            game_table => { '=', $game_table },
            game_id => {'=', $game->id}
       })->single();
       if($daily_game){
          $daily_game->update({play_date => $this_date_at_midnight});
       }else{
          my $daily_game = $c->model('DB::DailyGame')->create({
                                                      game_table => $game_table,
                                                      game_id => $game->id,
                                                      play_date => $this_date_at_midnight
                                      });
       }
       $game->update({scheduled_date => $this_date_at_midnight});
       $date = TodaysWord::Utilities::Date->getBriefDate($c, $date);
    }

    return $date;
}

=head1 NAME

TodaysWord::Model::DailyGame

=head1 SYNOPSIS

See L<TodaysWord>

=head1 DESCRIPTION

TodaysWord::Model::DailyGame

=head1 AUTHOR

marilyn

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;


