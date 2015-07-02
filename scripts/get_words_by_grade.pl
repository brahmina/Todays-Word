#!/usr/bin/perl

use strict;
#use warnings;

use DBI;

my $dbh;
my $state = 'process_source'; #process_source
my @grades = (1, 2, 3, 4, 5, 6, 7, 8);

if($state eq 'get_source'){
   get_from_source();
}elsif($state eq 'process_source'){
   process_source();
}

sub process_source {

   my $save_file; my $grade; my $line; my %words;
   foreach $grade(@grades) {
      $save_file = "/home/www-data/todays-word.com/scripts/dictionaries/words_by_grade/source-".$grade.".js";
      open FILE, "$save_file" || die "Cannot open file $save_file $!\n";
      my @lines = <FILE>;
      close FILE;

      print "read $save_file\n";

      foreach $line(@lines){
         if($line =~ m/vn\[v\]=(\d+);vw\[v\]="(\w+)";vp\[v\]="(\w+)";vd\[v\]="(.+)";v\+\+;/){
            $words{$2}{'lesson'} = $1;
            $words{$2}{'type'} = $3;
            $words{$2}{'grade'} = $grade;

            if(! $words{$2}{'def'}){
               $words{$2}{'def'} = $4;
            }else{
               $words{$2}{'def'} .= " ~~~ " . $4;
            }
         }
      }
   }

   init_db();

   foreach my $word(sort keys %words) {
      print "about to insert $word\n";
      my $stm = $dbh->prepare('INSERT INTO graded_words (word, grade, definition, type, lesson) VALUES (?, ?, ?, ?, ?)');
      $stm->execute($word,
                    $words{$word}{'grade'},
                    $words{$word}{'def'},
                    $words{$word}{'type'},
                    $words{$word}{'lesson'},
                    );
   }

   destroy_db();

}

sub get_from_source {

   use LWP::Simple;

   my $content; my $source; my $save_file; my $grade; my $lesson;
   foreach $grade(@grades) {

      $source = "http://www.aaaspell.com/vocab$grade.js";
      $save_file = "/home/www-data/todays-word.com/scripts/dictionaries/words_by_grade/source-".$grade.".js";

      print "source: $source\n";
      print "save_file: $save_file\n";

      $content = get($source);
      open FILE, "+>$save_file" || die "Cannot open file $save_file $!\n";
      print FILE $content;
      close FILE;

      sleep(2);
   }
}

sub init_db {

   $dbh = DBI->connect('dbi:mysql:Dictionary','wordy','wordsarethebest8392');

   if (!$dbh) {
      print"Unable to connect to database!\n";
      exit 1;
   }else{
      print "Connected to database \n";
   }
}

sub destroy_db {
   $dbh->disconnect();
}


print "cya\n";




