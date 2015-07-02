package TodaysWord::Model::Crossword;

use strict;

##################################################
sub get_crossword_data {
##################################################
   my ($self, $c, $id) = @_;

   my $crossword = $c->model('DB::Crossword')->find({id => $id});

   my @cells = $c->model('DB')->resultset('CrosswordCell')->search({
         crossword_id => { '=', "$id" }},
        {order_by => 'y, x' }
   );

   my @down_clues = $c->model('DB')->resultset('CrosswordClue')->search({
         crossword_id => { '=', "$id" },
         across_or_down => {'=', 'd'}
   });

   if(scalar(@down_clues) > 0){
      $down_clues[scalar(@down_clues)-1]->{'is_bottom_clue'} = 1;
      $down_clues[0]->{'is_top_clue'} = 1;
   }


   my @across_clues = $c->model('DB')->resultset('CrosswordClue')->search({
         crossword_id => { '=', "$id" },
         across_or_down => {'=', 'a'}
   });

   if(scalar(@across_clues) > 0){
      $across_clues[scalar(@across_clues)-1]->{'is_bottom_clue'} = 1;
      $across_clues[0]->{'is_top_clue'} = 1;
   }

   return ($crossword, \@cells, \@down_clues, \@across_clues);
}

=head1 NAME

TodaysWord::Model::Crossword - A play to keep the Crossword DB subs

=head1 SYNOPSIS

See L<TodaysWord>

=head1 DESCRIPTION

TodaysWord::Model::Crossword - A play to keep the Crossword DB subs

=head1 AUTHOR

marilyn

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;


