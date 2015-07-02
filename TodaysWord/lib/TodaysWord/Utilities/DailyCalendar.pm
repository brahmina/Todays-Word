package TodaysWord::Utilities::DailyCalendar;
use Moose;
use namespace::autoclean;

use TodaysWord::Utilities::CalendarMonthHTML;

##########################################################
# TodaysWord::DailyCalendar
##########################################################

=head1 NAME

   TodaysWord::Utilities::DailyCalendar.pm

=head1 SYNOPSIS

   $DailyCalendar = new TodaysWord::Utilities::DailyCalendar(Debugger);

=head1 DESCRIPTION

Wrapper for HTML Calendar

=head2 getCalendar

Gets the HTML calendar for the purpose specified

=over 4

=item B<Parameters :>

   1. $self - Reference to a TodaysWord::Utilities::DailyCalendar
   2. $game

=item B<Returns :>

   1. $CalendarHTML

=back

=cut

#############################################
sub getCalendarHTML {
#############################################
   my $self = shift;
   my $c = shift;
   my $month = shift;
   my $year = shift;
   my $game_param = shift;

   $c->log->debug("in TodaysWord::Utilities::DailyCalendar->getCalendarHTML with: month: $month, year: $year, game: $game_param");

   if(! $year || ! $month){
      return "<p><b>No month nor year passed</b></p>";
   }

   my %NumberOfDaysInMonth = ( 1 => 31, 2 => 28, 3 => 31, 4 => 30, 5 => 31, 6 => 30,
                               7 => 31, 8 => 31, 9 => 30, 10 => 31, 11 => 30, 12 => 31
                               );

   # Get all of the daily games for the month given
   use POSIX;
   my $StartOfMonth = mktime (0, 0, 0, 0, $month-1, $year-1900);
   my $EndOfMonth = mktime (59, 59, 23, $NumberOfDaysInMonth{$month}-1, $month-1, $year-1900);
   $c->log->debug("StartOfMonth: $StartOfMonth, EndOfMonth: $EndOfMonth");


   # Check for leap year
   if($month == 2){
      require TodaysWord::Utilities::Date;
      if(TodaysWord::Utilities::Date->isLeapYear($c, $year)){
         $EndOfMonth = mktime (59, 59, 23, 29, $month-1, $year-1900);
      }
   }

   my @daily_games;
   if($game_param ne ""){
      @daily_games = $c->model('DB')->resultset('DailyGame')->search({
         play_date => { "between", [$StartOfMonth, $EndOfMonth ] },
         game_table => {'=' , $game_param }
      });
   }else{
      @daily_games = $c->model('DB')->resultset('DailyGame')->search({
         play_date => { "between", [$StartOfMonth, $EndOfMonth ] },
      });
   }

   my %daily_games;
   my $warnings = "";
   foreach my $daily_game(@daily_games) {
      $c->log->debug("dailygame: " .$daily_game->play_date);
      my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($daily_game->play_date);
      my $day_scheduled = $mday;
      if($daily_games{$day_scheduled}{$daily_game->game_table}){
         $warnings .= "<b>Multiple games on $day_scheduled!</b><br />";
         $daily_games{$day_scheduled}{$daily_game->game_table} .= ", " . $daily_game->game_id;
      }else{
         $daily_games{$day_scheduled}{$daily_game->game_table} = $daily_game->game_id;
      }
   }

   my $cal = new TodaysWord::Utilities::CalendarMonthHTML();
   $cal->init($year, $month);
   $cal->border(0);
   $cal->headerclass('CalendarClass');



   use Date::Calc;
   my $this_month_name = Date::Calc::Month_to_Text($month);

   my $previous_month = $month-1;
   my $previous_year = $year;
   if($previous_month == 0){
      $previous_month = 12;
      $previous_year--;
   }
   my $previous_month_name = Date::Calc::Month_to_Text($previous_month);

   my $next_month = $month+1;
   my $next_year = $year;
   if($next_month == 13){
      $next_month = 1;
      $next_year++;
   }
   my $next_month_name = Date::Calc::Month_to_Text($next_month);

   my $g = "";
   if($game_param ne ""){
      $g = $game_param . "/";
   }

   my $header = qq~<a href='/admin/games/$g$previous_month/$previous_year' class='prev_cal'><< $previous_month_name</a>
                   <a href='/admin/games/$g$next_month/$next_year' class='next_cal'>$next_month_name >></a>
                   <center><font size='+2'>$this_month_name $year</font></center>~;
   $cal->header($header);


   my $this_days_games;
   foreach my $day(keys %daily_games) {
      $cal->setdatehref($day, "/admin/games/daily/$day");

      $this_days_games = "";
      foreach my $game(keys %{$daily_games{$day}}) {
         $c->log->debug("setting calendar $day $game : " . $daily_games{$day}{$game});
         $this_days_games .= "<a href='/admin/games/$game/show/".
                        $daily_games{$day}{$game}."' class='".$game."_calendar_link'>$game #".$daily_games{$day}{$game}."</a><br />";

         # Thumbnails for captions
         if($game_param eq "caption"){
            my $img = $c->config->{full_path} . '/static/captions/' . $daily_games{$day}{$game} . ".png";
            if( ! -e $img){
               $img = $c->config->{full_path} . '/static/captions/' . $daily_games{$day}{$game} . ".jpg";
            }elsif(! -e $img){
               $img = $c->config->{full_path} . '/static/captions/' . $daily_games{$day}{$game} . ".gif";
            }elsif(! -e $img){
               $img = $c->config->{full_path} . '/static/captions/' . $daily_games{$day}{$game} . ".jpeg";
            }
            my $path = $c->config->{full_path};
            $img =~ s/$path//;
            $this_days_games .= "<img src='$img' class='calendar_caption_img' />"
         }
      }
      $this_days_games =~ s/<br \/>$//;
      $cal->setcontent($day, $this_days_games);
   }


   return $warnings . $cal->as_HTML;
}

=head2 setDailyCalendar

Writes content to the DailyCalendar for the file requested

=over 4

=item B<Parameters :>

   1. $self - Reference to a TodaysWord::Utilities::DailyCalendar object
   2. $file_requested
   3. $page_content

=back

=cut

#############################################
sub setDailyCalendar {
#############################################
   my $self = shift;

   #$c->log->debug("in TodaysWord::Utilities::DailyCalendar->setDailyCalendar");

}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;



