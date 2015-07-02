package TodaysWord::Model::Advert;

use strict;
use TodaysWord::Setup;

##################################################
sub process_template {
##################################################
   my ($self, $c) = @_;

   my $template = $c->{stash}->{template};
   open(TEMPLATE, $TodaysWord::Setup::PATH.'/'.$template) || die "Cannot open template: $template";
   my @lines = <TEMPLATE>;
   close TEMPLATE;

   foreach my $line(@lines) {
      if($line =~ m/<!-- ADVERT ([\d,]+) -->/){
         my $params = $1;
         my @pieces = split(',', $params);

         my $position;
         if(scalar(@pieces) == 3){
            $position = $pieces[2];
         }else{
            $position = rand($#pieces);
         }

         my $advert = TodaysWord::Model::Advert->get_advert($c, $pieces[0], $pieces[1], $position);
                                                                # width,     height,     position             
         $line =~ s/<!-- ADVERT $params -->/$advert.code/;
      }
   }
}

##################################################
sub get_advert {
##################################################
   my ($self, $c, $width, $height, $position) = @_;

   $width =~ s/px//;
   $height =~ s/px//;

   my @adverts = $c->model('DB')->resultset('Advert')->search({
        status => { '=', $TodaysWord::Setup::ADVERT_RUNNING },
        width => { '<=' => $width },
        height => { '<=' => $height }
   });

   $position = $position % scalar(@adverts);

   if($position){
      return $adverts[$position];
   }else{
      return $adverts[$position];
   }   
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

