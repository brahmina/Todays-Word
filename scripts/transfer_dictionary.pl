#!/usr/bin/perl

use strict;
#use warnings;

use DBI;

my $dbh = DBI->connect('dbi:mysql:TodaysWord',
                       'wordy',
                       'wordsarethebest8392');

if (!$dbh) {
   print"Unable to connect to database!\n";
   exit 1;
}else{
   print "Connected to database \n";
}

my $i = 0;
my %words;
my $sql = "select * from dict_word_full where frequency is not null and definition is not null";
print STDERR "$sql\n";
my $stm = $dbh->prepare($sql);
if ($stm->execute()) {
   while (my $hash = $stm->fetchrow_hashref()) {

      $words{$i} = $hash;
      $i++;
   }
}else{
   print "ERROR: with SELECT: $sql - $DBI::errstr\n";
}
$stm->finish;

my $stm = $dbh->prepare('INSERT INTO dict_word (word, definition, synonym, frequency, status) VALUES (?, ?, ?, ?, ?)');
foreach my $i(sort{$words{$a}->{'word'} cmp $words{$b}->{'word'}} keys %words) {
   $stm->execute( $words{$i}->{'word'},
                  $words{$i}->{'definition'},
                  $words{$i}->{'synonym'},
                  $words{$i}->{'frequency'},
                  $words{$i}->{'status'}
                  );
   print STDERR "inserting $words{$i}->{word}\n";
   $words{$i}->{'inserted'} = 1;
}

my %words;
my $sql = "select * from dict_word_full";
print STDERR "$sql\n";
my $stm = $dbh->prepare($sql);
if ($stm->execute()) {
   while (my $hash = $stm->fetchrow_hashref()) {

      $words{$i} = $hash;
      $i++;
   }
}else{
   print "ERROR: with SELECT: $sql - $DBI::errstr\n";
}
$stm->finish;

my $stm = $dbh->prepare('INSERT INTO dict_word (word, definition, synonym, frequency, status) VALUES (?, ?, ?, ?, ?)');
foreach my $i(sort{$words{$a}->{'word'} cmp $words{$b}->{'word'}} keys %words) {
   if( ! $words{$i}->{'inserted'}){
      $stm->execute( $words{$i}->{'word'},
                     $words{$i}->{'definition'},
                     $words{$i}->{'synonym'},
                     $words{$i}->{'frequency'},
                     $words{$i}->{'status'}
                     );
      print STDERR "inserting $words{$i}->{word}\n";
      $words{$i}->{'inserted'} = 1;
   }
}

$dbh->disconnect();

print "cya\n";


