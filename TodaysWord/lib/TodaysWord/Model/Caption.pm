package TodaysWord::Model::Caption;

use strict;

##################################################
sub get_caption_data {
##################################################
   my ($self, $c, $id) = @_;

   my $caption = $c->model('DB::Caption')->find({id => $id});

   my @bubbles = $c->model('DB')->resultset('CaptionBubble')->search({
        caption_id => { '=', $id }
   });

   my $bubble_count = scalar(@bubbles);
   if($bubble_count){
      my $count = 1;
      foreach my $bubble (@bubbles) {
         $bubble->{'count'} = $count;
         $count++;
      }
   }else{
      $bubble_count = 0;
   }

   # Get the width and height of the image for the dynamic css or the
   #   div of width the image will be the background of
   my $file_location = $c->config->{full_path}.$caption->optimized_location;
   my $command = "identify $file_location";
   my $output = system($command);

   return ($caption, \@bubbles, $bubble_count);
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


