package TodaysWord::Controller::Games::Caption;
use Moose;
use namespace::autoclean;

use TodaysWord::Model::Caption;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

TodaysWord::Controller::Games::Caption - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash( template => 'games/caption/captions.tt', captions => [$c->model('DB')->resultset('Caption')->all]);
}


=head2 play

=cut

sub play :Local {
    my ($self, $c, $id) = @_;


    my ($caption, $bubbles, $bubble_count) = TodaysWord::Model::Caption->get_caption_data($c, $id);

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
                                             game_table => 'caption',
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

    $c->stash( template => 'games/caption/caption.tt', caption => $caption, bubbles => $bubbles, bubble_count => $bubble_count,
                     game_play => $game_play, timer_start => $timer_start);
}

=head2 done

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

    my $game_play = $c->model('DB::GamePlay')->find({id => $game_play_id});

    # TODO - Save the captions_entries for each bubble

    my ($caption, $bubbles, $bubble_count) = TodaysWord::Model::Caption->get_caption_data($c, $game_play->game_id);

    # TODO - implement timed edit
    #  - on time limit expiry, do ajax remove edit button
    #  - if edited, the time taken to edit will be added to the total time


    $c->stash( template => 'games/caption/done_caption.tt', game_play => $game_play, caption => $caption,
                     bubbles => $bubbles, bubble_count => $bubble_count);
}

=head2 rate_captions

=cut

sub rate_captions :Local {
    my ($self, $c) = @_;


    my $game_play = $c->model('DB::GamePlay')->find({id => $c->req->param('gpid')});

    # TODO - Save the captions_entries for each bubble

    my ($caption, $bubbles, $bubble_count) = TodaysWord::Model::Caption->get_caption_data($c, $game_play->game_id);

    $c->stash( template => 'games/star_rating.tt', game_play => $game_play);
}

=head2 rate

=cut

sub rate :Local {
    my ($self, $c, $game_play_id, $rating) = @_;

    my $waittime = time() + 15;
    while (time() < $waittime) {}

    my $game_play = $c->model('DB::GamePlay')->find({id => $game_play_id});

    # TODO - Save and calculate rating

    if($c->user_exists){
       # Has this person rated this entry yet?
       my $game_rating = $c->model('DB::GameRating')->find({game_play_id => $game_play_id, user_id => $c->user->id});
       if($game_rating->id){
          $game_rating->update({rating => $rating, create_date => time()});
       }else{
          my $game_rating = $c->model('DB::GameRating')->create({
                                             game_play_id => $game_play_id,
                                             user_id => $c->user->id,
                                             create_date => time(),
                                             ip => $c->request->address,
                                             status => 1
                                      });
       }
    }else{
       # What to do with guest ratings?
    }



    if($c->req->param('ajax') == 1){
       $c->stash( template => 'games/rating.tt', game_play => $game_play, game => 'caption');
    }else{
       my ($caption, $bubbles, $bubble_count) = TodaysWord::Model::Caption->get_caption_data($c, $game_play->game_id);

       $c->stash( template => 'games/caption/rate_caption.tt', game_play => $game_play, caption => $caption,
                        bubbles => $bubbles, bubble_count => $bubble_count, game => 'caption');
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

