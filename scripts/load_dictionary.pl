#!/usr/bin/perl

use strict;
#use warnings;

# Problems
# Does not parse <mhw>'s 

use DBI;

my $base_dir = "/home/www-data/todays-word.com/scripts/";
my @alpha = ('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z');

my %symbols = (  "<Cced/" => "Ç",
                 "<uum/" => "ü",
                 "<acir/" => "â",
                 "<aum/" => "ä",
                 "<agrave/" => "à",	
                 "<aring/" => "å",
                 "<cced/" => "ç",
                 "<ecir/" => "ê",
                 "<eum/" => "ë",
                 "<egrave/" => "è",
                 "<ium/" => "ï",
                 "<icir/" => "î",
                 "<Eacute/" => "É",
                 "<ae/" => "æ",
                 "<AE/" => "Æ",
                 "<ocir/" => "ô",
                 "<oum/" => "ö",
                 "<ucir/" => "û",
                 "<Uum/" => "Ü",
                 "<pound/" => "£",
                 "<ntil/" => "ñ",
                 "<frac14/" => "¼",
                 "<frac12/" => "½",
                 "<frac34/" => "¾",
                 "<amac/" => "ā",
                 "<hand/" => "&#9758;", # ☞
                 "<sect/" => "§",
                 "<nsm/" => "&#331;", # ŋ
                 "<sharp/" => "&#9839;",
                 "<flat/" => "&#9837",
                 "<imac/" => "ī",
                 "<emac/" => "ē",
                 "<omac/" => "ō",
                 "<umac/" => "ū",
                 "<acr/" => "ă",
                 "<ecr/" => "ĕ",
                 "<icr/" => "ĭ",
                 "<ocr/" => "ȏ",
                 "<ucr/" => "ŭ",
                 "<br/ " => "<br />"
                 );

my %parts_of_speech =   (
                           "adj." => "Adjective",
                           "n." => "Noun",
                           "prep." => "Preposition",
                           "prop. n." => "Proper noun",
                           "adv." => "Adverb",
                           "a." => "Adjective",
                           "adjective" => "Adjective",
                           "v. t." => "Verb",
                           "p. a." => "Proper adjective",
                           "v. i." => "Verb",
                           "imp." => "Past participle",
                           "p. p." => "Past participle",
                           "imp. & p. p." => "Past participle",
                           "adv. & a." => "Adjective",
                           "n. pl." => "Noun plural",
                           "interj." => "Interjection",
                           "v.!" => "Verb",
                           "conj." => "Conjunction"
                           );


# Get the word frequencies
my $frequency_file = "$base_dir/dictionaries/anc-lexicon-frequencies-cleaned.dat";
open (FILE, $frequency_file) || die "Cannot open file: $frequency_file -> $!\n";
my @lines = <FILE>;
close(FILE);

my %word_frequencies;
my $line_counter = 0;
foreach my $line(@lines) {
   my ($word, $freq) = split(' ', $line);
   $word_frequencies{$word} = $freq;
}

# Get the common crosswords
my $common_file = "$base_dir/dictionaries/common_crossword_words.txt";
open (FILE, $common_file) || die "Cannot open file: $common_file -> $!\n";
@lines = <FILE>;
close(FILE);

my $word;
my %common_crossword_words;
$line_counter = 0;
foreach my $line(@lines) {
    if($line !~ m/#/){
   		$word = $line;
   		chomp($word);
   		$common_crossword_words{$word} = 1;
	}
}


# Now for the real dictionary!
my %words;
my $word_counter = 1;
my %missing_parts_of_speech;
foreach my $letter(@alpha) {
   print "\n\n---------------- $letter ----------------\n\n";
   my $filename = "$base_dir//dictionaries/dictionary-0.43/cide.$letter";
   open (FILE, $filename) || die "Cannot open file: $filename -> $!\n";
   my @lines = <FILE>;
   close(FILE);

   my $line_counter = 0;
   my $innards; my $word; my $word_orig; my $definition; my $etymology; my $synonyms; my $part_of_speech; my $def;
   foreach my $line(@lines) {
      if($line =~ m/<p>(.+)<\/p>?/){
         $innards = $1;

         $part_of_speech = ""; $definition = ""; $etymology = ""; $synonyms = "";

         if($innards =~ m/<hw>(.+)<\/hw>?/){
            $word = $1;
            $word_orig = $word;
            $word =~ s/\"//g;
            $word =~ s/\*//g;
            $word =~ s/\`//g;
            $word = lc($word);
            $word_counter++;
         }else{
            # We are adding to the previous word

         }

         if($innards =~ m/<pos>([\w\. ]+)<\/pos>?/){
            $part_of_speech = $1;
         }
         
         while($innards =~ m/<def>(.+)<\/def>?/g){
            $def = $1;
            foreach my $from (keys %symbols){
            	$def =~ s/$from/$symbols{$from}/g;
            }
            $def =~ s/<\w+>//g;
            $def =~ s/<\/\w+>//g;

            if($part_of_speech){
               if($parts_of_speech{$part_of_speech}){
                  $def = "($parts_of_speech{$part_of_speech}) $def";
               }else{
                  print "!!!!!!!!!! No part of speech match for $part_of_speech!\n";
                  $missing_parts_of_speech{$part_of_speech} = 1;
                  $def = "($part_of_speech) $def";
               }
               
            }
            
            $definition .= $def ."~~~";
         }
         $definition =~ s/~~~$//;
         
         if($innards =~ m/<syn><b>Syn. --<\/b> (.+)<\/syn>?/){
            $synonyms = $1;
         }         
         if($innards =~ m/<ety>(.+)<\/ety>?/){
            $etymology = $1;
         }

         if($word =~ m/\W+/){
            next;
         }

         print "found word -> $word\n";
         
         $words{$word}{'word_orig'} = $word_orig; 

         if($words{$word}{'part_of_speech'} && $part_of_speech){
            $words{$word}{'part_of_speech'} = $words{$word}{'part_of_speech'} . "~~~" . $part_of_speech;
         }elsif($part_of_speech){
            $words{$word}{'part_of_speech'} = $part_of_speech;
         }
         if($words{$word}{'definition'} && $definition){
            $words{$word}{'definition'} = $words{$word}{'definition'} . "~~~" . $definition;
         }elsif($definition){
            $words{$word}{'definition'} = $definition;
         }
         if($words{$word}{'synonyms'} && $synonyms){
            $words{$word}{'synonyms'} = $words{$word}{'synonyms'} . "~~~" . $synonyms;
         }elsif($synonyms){
            $words{$word}{'synonyms'} = $synonyms;
         }
         if($words{$word}{'etymology'} && $etymology){
            $words{$word}{'etymology'} = $words{$word}{'etymology'} . "~~~" . $etymology;
         }elsif($etymology){
            $words{$word}{'etymology'} = $etymology;
         }
      }

      $line_counter++;
   }
}

# Now for the wiki words
my $filename = "$base_dir//dictionaries/enwikt-defs-latest-en.tsv";
open (FILE, $filename) || die "Cannot open file: $filename -> $!\n";
@lines = <FILE>;
close(FILE);

foreach my $line (@lines){

	$line =~ s/^English\s//;
	
	my @pieces = split('\t', $line);

	my $word = $pieces[0];
	$word = lc($word);
	
	if($word =~ m/\W+/){
		next;
	}
	
	my $origin = $pieces[1];
	$origin =~ s/\{//g;
	$origin =~ s/\}//g;
	
	my $def = $pieces[2];
	$def =~ s/^# //;
	$def =~ s/\{//g;
	$def =~ s/\}//g;
	$def =~ s/\[\[w://g;
	$def =~ s/\[\[//g;
	$def =~ s/\]\]//g;
	$def =~ s/\|/ /g;
	$def =~ s/''/'/g;
	$def =~ s/'''/"/g;
	
	if($words{$word}{'definition_wiki'}){
		$words{$word}{'definition_wiki'} .= "~~~($origin) $def";
	}else{
		$words{$word}{'definition_wiki'} = "($origin) $def";
	}
}


print "found $word_counter words\n";

my $dbh = DBI->connect('dbi:mysql:Dictionary',
                       'wordy',
                       'wordsarethebest8392');

if (!$dbh) {
   print"Unable to connect to database!\n";
   exit 1;
}else{
   print "Connected to database \n";
}

sub sort_words {

	return $a cmp $b;

    if ( (($words{$a}{'definition'} cmp $words{$b}{'definition'}) != 0) && ((($words{$a}{'frequency'} <=> $words{$b}{'frequency'}) != 0))) {
       return $words{$a}{'definition'} cmp $words{$b}{'definition'};
    }elsif ( ($words{$a}{'definition'} cmp $words{$b}{'definition'}) != 0 ) {
       return $words{$a}{'definition'} cmp $words{$b}{'definition'};
    }elsif ( ($words{$a}{'frequency'} <=> $words{$b}{'frequency'}) != 0) {
       return $words{$a}{'frequency'} <=> $words{$b}{'frequency'};
    }else {
       return $a cmp $b;
    }
}

my $stm = $dbh->prepare('INSERT INTO dict_word (word, word_orig, definition, definition_wiki, synonym, etymology, common, frequency, rating) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)');


my $common = 0;
foreach my $word(sort sort_words keys %words) {

	$common = 0;
	if($common_crossword_words{$word}){
		$common = 1;
	}
	
	my $rating = 0;
	if($words{$word}{'definition'} && $words{$word}{'definition_wiki'} && $words{$word}{'synonyms'} && $word_frequencies{$word}){
		$rating = 5;
	}elsif($words{$word}{'definition'} && $words{$word}{'definition_wiki'} && $word_frequencies{$word}){
		$rating = 4;
	}elsif($words{$word}{'definition'} && $word_frequencies{$word}){
		$rating = 3;
	}elsif($words{$word}{'definition'}){
		$rating = 2;
	}elsif($words{$word}{'definition_wiki'}){
		$rating = 1;
	}
	
	
    print "INSERT -> " .$word . ", " . $words{$word}{'definition'} . ", " . $words{$word}{'definition_wiki'} . "\n";
    $stm->execute($word, $words{$word}{'word_orig'}, $words{$word}{'definition'}, $words{$word}{'definition_wiki'},
    				$words{$word}{'synonyms'}, $words{$word}{'etymology'}, 
    				$common, $word_frequencies{$word}, $rating);
}

$dbh->disconnect();

print "Missing parts of speech:\n";
foreach (keys %missing_parts_of_speech) {
   print "$_\n";
}

print "cya\n";










