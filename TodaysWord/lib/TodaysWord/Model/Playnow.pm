package TodaysWord::Model::Playnow;

use strict;

=head2 get_all_games

=cut

sub get_all_games {
   my ($self, $c, %params) = @_;

   my $order_by = {-asc => 'sort_order'}; 
   if($params{'order_by_releasable'}){
      $order_by = {-asc => 'releasable', -asc => 'sort_order' };
   }else{
      $order_by = {-asc => 'sort_order'};
   }

   my @games = $c->model('DB')->resultset('Playnow')->search(
                            { status => { '=', 1 } }, 
                            { order_by => $order_by }
                        );

   return \@games;
}

=head2 get_all_releasable_games

=cut

sub get_all_releasable_games {
   my ($self, $c) = @_;

   my @games = $c->model('DB')->resultset('Playnow')->search(
                            { 
                              status => { '=', 1 },
                              releasable => { '=', 1 }
                             }, 
                            { order_by => {-asc => 'sort_order'} }
                        );

   return \@games;
}

sub get_releasable_games {
   my ($self, $c, $page) = @_;

   my @games = $c->model('DB')->resultset('Playnow')->search(
                            { 
                              status => { '=', 1 },
                              releasable => { '=', 1 }
                             }, 
                            { 
                              order_by => {-asc => 'sort_order'} ,
                              rows => $TodaysWord::Setup::PLAYNOW_GAMES_PER_PAGE,
                              offset => ($TodaysWord::Setup::PLAYNOW_GAMES_PER_PAGE * $page) - $TodaysWord::Setup::PLAYNOW_GAMES_PER_PAGE
                            }
                        );

   return \@games;
}

sub get_all_releasable_games_count {
   my ($self, $c) = @_;

   my $games = $self->get_all_releasable_games($c);

   return scalar(@{$games});
}

=head2 get_dimensions_from_code

=cut

sub get_dimensions_from_code {
    my ( $self, $c, $code ) = @_;

    my $width; my $height;

    my $double_quotes = 0;
    if($code =~ m/width="(\d+)/){
       $width = $1;
       if($code =~ m/height="(\d+)/){
          $height = $1;
       }
       $double_quotes = 1;
    }elsif($code =~ m/width='(\d+)/){
       $width = $1;
       if($code =~ m/height='(\d+)/){
          $height = $1;
       }
    }else{
       $c->log->debug("Playnow added using default width and height!");
       $width = 600;
       $height = 500;
    }

    return ($width, $height);
}

=head2 get_playnow_ratings

=cut

sub get_playnow_ratings {
    my ( $self, $c, $playnow_id ) = @_;
    
    my @ratings = $c->model('DB')->resultset('PlaynowRating')->search(
                            { playnow_id => { '=', $playnow_id } }
                        );

    return \@ratings;
}

=head2 get_current_playnow_rating

=cut

sub get_current_playnow_rating {
    my ( $self, $c, $playnow_id ) = @_;
    
    my $playnow_ratings = $self->get_playnow_ratings($c, $playnow_id);
    
    my $rating_sum = 0; my $rating_count = 0;
    foreach my $playnow_rating (@{$playnow_ratings}){
        $rating_sum +=  $playnow_rating->rating;
        $rating_count++;
    }
    
    my $rating = 0;
    if($rating_count){
       $rating = $rating_sum / $rating_count;
    }

    $rating = sprintf("%.2f", $rating);

    return ($rating, $rating_count);
}

=head2 get_current_rating_width

=cut

sub get_current_rating_width {
    my ( $self, $c, $rating ) = @_;
    
    my $width = int($rating) * 54;

    return $width;
}

=head2 get_playnow_game 

=cut

sub get_playnow_game {
    my ( $self, $c, $playnow_id ) = @_;
    
    my $game = $c->model('DB')->resultset('Playnow')->find(
                            { 
                                id => { '=', $playnow_id },
                                status => { '=', 1 }
                            }
                        );
    if(! $game){
        return undef;
    }

    my $original_code = $game->code;
    my $code = $original_code;

    if(0){
       my ($width, $height) = $self->get_dimensions_from_code($c, $code);
       my $to_width = $game->width;
       $code =~ s/width="$width"/width="$to_width"/g;
   
       my $to_height = $game->height;
       $code =~ s/height="$height"/height="$to_height"/g;
       $game->{orginal_code} = $original_code;
       $game->code($code);
    }
    
    
    return $game;
}

=head2 get_highest_rated_games 

=cut

sub get_highest_rated_games {
    my ( $self, $c ) = @_;

    my @ratings = $c->model('DB')->resultset('PlaynowRating')->all();

    my %playnows;
    foreach my $rating (@ratings) {
       if($playnows{$rating->playnow_id}->{'count'}){
          $playnows{$rating->playnow_id}->{'sum'} += $rating->rating;
          $playnows{$rating->playnow_id}->{'count'}++;
       }else{
          $playnows{$rating->playnow_id}->{'sum'} = $rating->rating;
          $playnows{$rating->playnow_id}->{'count'} = 1;
       }
    }

    foreach my $playnow(keys %playnows) {
       $playnows{$playnow}->{'average_rating'} = $playnows{$playnow}->{'sum'} / $playnows{$playnow}->{'count'};
    }
    my @ids; my $count = 0;
    foreach my $playnow_id(sort{$playnows{$a}->{'average_rating'} <=> $playnows{$b}->{'average_rating'}}keys %playnows) {
       if($count >= 8){
          last;
       }
       push(@ids, $playnow_id);
    }

    my @games = $c->model('DB')->resultset('Playnow')->search(
                            { 
                                id => { 'IN', \@ids },
                                releasable => { '=', 1 },
                                status => { '=', 1 }
                            }
                        );

    my @rated_games;
    if(scalar(@games) > 10){ # 10 spots on the main index page (featured games)
       @rated_games = @games[0..9];
    }else{
       @rated_games = @games;
    }
    return \@rated_games;
}

=head1 NAME

TodaysWord::Model::Playnow - A play to keep the TodaysWord DB subs

=head1 SYNOPSIS

See L<TodaysWord>

=head1 DESCRIPTION

TodaysWord::Model::Playnow

=head1 AUTHOR

marilyn

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

