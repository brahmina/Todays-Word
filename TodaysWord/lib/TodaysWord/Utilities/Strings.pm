package TodaysWord::Utilities::Strings;
use Moose;
use namespace::autoclean;

=head1 NAME

TodaysWord::Utilities::Strings 

=head1 DESCRIPTION

Strings method wrapper

=head1 METHODS

=cut


=head2 getSEO

Given a string in english, returns the string converted url/seo format

- lower case
- spaces -> _
- non word characters removed

=over 4

=item B<Parameters :>

   1. $string - The tring to be formatted

=item B<Returns :>

   1. $seo_strin - SEO friendly string

=back

=cut


#############################################
sub getSEO {
#############################################
   my $string = shift;

   my $seo_string = lc($string);
   $seo_string =~ s/ /_/g;
   $seo_string =~ s/\W+//g;

   return $seo_string;
}


=head1 AUTHOR

Marilyn

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;


