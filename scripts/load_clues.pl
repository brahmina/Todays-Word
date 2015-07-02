#!/usr/bin/perl

use strict;
#use warnings;

use DBI;

my %clues;

my $base_dir = "/home/www-data/todays-word.com/scripts/";
my $filename = "$base_dir/dictionaries/American.csv";
open (FILE, $filename) || die "Cannot open file: $filename -> $!\n";
my @lines = <FILE>;
close(FILE);

my %clues;
my %words;
my $line_counter = 0;
foreach my $line(@lines) {
   my @pieces = split(',', $line);

   my $word = $pieces[0];

   my $clue = "";
   for (my $i = 1; $i < scalar(@pieces); $i++) {
      $clue .= $pieces[$i] . ",";
   }

   $clue =~ s/,$//g;
   $clue =~ s/\n//g;
   $clue =~ s/^\s//g;
   $clue =~ s/\s$//g;

   $word = lc($word);
   if($clues{$clue}){
      $clues{$clue} .= "~".$word;
   }else{
      $clues{$clue} .= $word;
   }
   $line_counter++;
}

# TODO - convert words to lower case here and in dictionary to prevent dupes.
#      - concat the definitions


print "found $line_counter clues\n";

#my $schema = TodaysWord::Schema->connect(, 'wordy', 'wordsarethebest8392');
my $dbh = DBI->connect('dbi:mysql:Dictionary',
                       'wordy',
                       'wordsarethebest8392');

if (!$dbh) {
   print"Unable to connect to database!\n";
   exit 1;
}else{
   print "Connected to database \n";
}

my %words;

foreach my $clue(sort{$a cmp $b} keys %clues) {


   # Insert the dict_clue first

   my @words = split("~",$clues{$clue});
   my $stm = $dbh->prepare('INSERT INTO dict_clue (clue) VALUES (?)');
   $stm->execute($clue);
   my $clueid = $stm->{mysql_insertid};
   print "inserted dict_clue $clue -> $clueid\n";

   foreach my $word (@words) {

      my $wordid;
      if(! $words{$word}){
         # See if it's in there from the dictionary
         my $worddb;

         $word =~ s///;

         my $sql_select = "SELECT * FROM dict_word WHERE word = ?";
         my $stm = $dbh->prepare($sql_select);
         if ($stm->execute($word)) {
            while (my $hash = $stm->fetchrow_hashref()) {
               $worddb = $hash;
            }
         }else{
            print "ERROR: with SELECT: $sql_select - $DBI::errstr\n";
         }
         $stm->finish;

         if(!$worddb->{id}){
            # not in the db yet
            $stm = $dbh->prepare('INSERT INTO dict_word (word) VALUES (?)');
            $stm->execute($word);
            $wordid = $stm->{mysql_insertid};
            print "inserted dict_word $word -> $wordid\n";
         }else{
            print "found dict_word $word -> $wordid\n";
            $wordid = $worddb->{id};
         }
         $words{$word} = $wordid;
      }else{
         $wordid = $words{$word};
      }

      # now for the dict_word_clue entry
      $stm = $dbh->prepare('INSERT INTO dict_word_clue (word_id, clue_id) VALUES (?, ?)');
      $stm->execute($wordid, $clueid);
   }
}

$dbh->disconnect();

print "cya\n";

