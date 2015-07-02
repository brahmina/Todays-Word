#!/usr/bin/perl

use strict;
#use warnings;

use DBI;

my $dbh = DBI->connect('dbi:mysql:Dictionary',
                       'wordy',
                       'wordsarethebest8392');

if (!$dbh) {
   print"Unable to connect to database!\n";
   exit 1;
}else{
   print "Connected to database \n";
}

my %clues;
my $sql_select = "SELECT id, clue from dict_clue";
my $stm = $dbh->prepare($sql_select);
if ($stm->execute()) {
   while (my $hash = $stm->fetchrow_hashref()) {
      $clues{$hash->{id}} = $hash->{clue};
   }
}else{
   print "ERROR: with SELECT: $sql_select - $DBI::errstr\n";
}
$stm->finish;

foreach my $id (keys %clues) {

   my $clue = $clues{$id};

   $clue =~ s/\"//;

   $clue =~ s/\"/\\\"/g;

   my $sqlu = "UPDATE dict_clue SET clue = \"$clue\"";
   my $stm = $dbh->prepare($sqlu);
   if ($dbh->do($sqlu)) {
      # Good Stuff
   }else {
      print "ERROR: with  UPDATE::: $sqlu\n";
   }
}

$dbh->disconnect();

print "cya\n";


