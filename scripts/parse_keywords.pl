#!/usr/bin/perl

use strict;
#use warnings;

use DBI;

my $dbh = DBI->connect('dbi:mysql:Keywords',
                       'wordy',
                       'wordsarethebest8392');

if (!$dbh) {
   print"Unable to connect to database!\n";
   exit 1;
}else{
}

my $shift_time = 60*60*24*7;
my @fields_to_shift = ('acro.scheduled_date', 'acro.played_date', 'acro_phrase.create_date',
                       'caption.scheduled_date', 'caption.played_date', 'caption_entry.create_date',
                       'crossword.scheduled_date', 'crossword.played_date',
                       'sudoku.scheduled_date', 'sudoku.played_date',
                       'todays_word.scheduled_date', 'todays_word.played_date',
                       'daily_game.play_date',
                       'game_play.start_time', 'game_play.end_time',
                       'game_rating.create_date',
                       'game_timer.start_time', 'game_timer.end_time',
                       'prize.date_won', 'prize.date_sent'
                       );

my $sql; my $table; my $fld;
foreach my $field(@fields_to_shift) {
   ($table, $fld) = split(/\./, $field);
   $sql = "update $table set $fld = $fld + $shift_time";
   if(! $dbh->do($sql)){
      #print "Failed to do $sql!\n";
   }else{
      #print "Updated $field\n";
   }
}

$dbh->disconnect();

#print "cya\n";







