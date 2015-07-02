package TodaysWord::Model::TodaysWord;

use strict;

##################################################
sub process_word {
##################################################
   my ($self, $c, $word) = @_;

   if(! $word){
      return;
   }
   if($word->definition){
      my @definitions = split(" ~~~ ", $word->definition);
      $word->{definitions} = "<ul class='todaysword_definitions'>";
      foreach my $def(@definitions) {
         $word->{definitions} .= "<li>$def</li>";
      }
      $word->{definitions} .= "</ul>";
   }
   if($word->synonym){
      my @synonyms = split(" ~~~ ", $word->synonym);
      $word->{synonyms} = "<ul class='todaysword_synonyms'>";
      foreach my $syn(@synonyms) {
         $word->{synonyms} .= "<li>$syn</li>";
      }
      $word->{synonyms} .= "</ul>";
   }

   my @dict_word_clues = $c->model('DictDB')->resultset('DictWordClue')->search({
        word_id => { '=', $word->id }
   });

   my @clues;
   foreach my $dict_word_clue(@dict_word_clues) {
      my $clue = $c->model('DictDB')->resultset('DictClue')->find({id => $dict_word_clue->clue_id});
      push( @clues, $clue );
      $c->log->debug("clue: " . $clue->clue);
   }
   if(scalar(@clues) > 0){
      $word->{clues} = \@clues;
   }

}

=head1 NAME

TodaysWord::Model::TodaysWord - A play to keep the TodaysWord DB subs

=head1 SYNOPSIS

See L<TodaysWord>

=head1 DESCRIPTION

TodaysWord::Model::TodaysWord - A play to keep the TodaysWord DB subs

=head1 AUTHOR

marilyn

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;



