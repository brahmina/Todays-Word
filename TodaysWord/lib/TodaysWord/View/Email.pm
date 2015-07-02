package TodaysWord::View::Email;

use strict;
use base 'Catalyst::View::Email';

__PACKAGE__->config(
    stash_key => 'email'
);

=head1 NAME

TodaysWord::View::Email - Email View for TodaysWord

=head1 DESCRIPTION

View for sending email from TodaysWord.

=head1 AUTHOR

root

=head1 SEE ALSO

L<TodaysWord>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;


