package TodaysWord::Model::DictWord;

use strict;

use TodaysWord::Utilities::Date;

=item get_todays_word

Gets a word from the dictionary with all associated definitions etc to be today's word

=cut

##################################################
sub get_todays_word {
##################################################
    my ( $self, $c ) = @_;

    my $word = $self->get_word($c, seed => undef, todayswordworthy => 1);

    return $word;
}

=item get_word

Gets a word from the dictionary with all associated definitions etc

=cut

##################################################
sub get_word {
##################################################
    my ( $self, $c, %params ) = @_;

    my $seed = $params{'seed'};
    if(! $seed){
       # 29288 is how many words in dict_word
       my $DateUtility = new TodaysWord::Utilities::Date();
       $seed = $DateUtility->getTodayAtMidnight();
    }
    srand($seed);
    my $random_id = int(rand(1384));#19938)); # 19938 the number of words with a rating of 4 or higher (1385 for rating of 5)

    my $word;
    my $word_str = undef; 
    if(!$word_str){
      $word = $c->model('DictDB::DictWord')->search(
    						{ # constaints
    							rating => {'>=' => 5},
                                                        todayswordworthy => {'=' => 1}
    						},
    						{ # extras
          						rows => 1,
          						page => $random_id,
         					    order_by => { -asc => 'id' }
        					}
    				)->single;
     }else{
        # For fixing specific words when problems arise
        $word = $c->model("DictDB::DictWord")->find({word => $word_str});			
     }

     if(! $word){
        $c->log->debug("No word found?!?! random_id: $random_id, seed: $seed");
     }

     my @definitions = split("~~~", $word->definition);
     if(scalar(@definitions)){
        $word->{definitions} = \@definitions;
     }
     
     my @wiki_definitions = split("~~~", $word->definition_wiki);
     if(scalar(@wiki_definitions)){
        $word->{wiki_definitions} = \@wiki_definitions;
     }
     
     my @synonyms = split("~~~", $word->synonym);
     if(scalar(@synonyms)){
        my @syns;
        foreach my $s(@synonyms) {
           $s =~ s/\.$//;
           push(@syns, split(", ", $s));
        }
        $word->{synonyms} = \@syns;
     }

    return $word;
}

=head1 NAME

TodaysWord::Model::DictWord

=head1 SYNOPSIS

See L<TodaysWord>

=head1 DESCRIPTION

TodaysWord::Model::DictWord

=head1 AUTHOR

marilyn

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
