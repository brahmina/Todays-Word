package TodaysWord::Model::Article;

use strict;

##################################################
sub get_all_articles {
##################################################
   my ($self, $c) = @_;

   my @articles = $c->model('DB')->resultset('Article')->search(
                            { status => { '=', 1 } }, 
                            { order_by => {-asc => 'written_where'} }
                        );
   return \@articles;
}

=head1 NAME

TodaysWord::Model::Article - A play to keep the TodaysWord DB subs

=head1 SYNOPSIS

See L<TodaysWord>

=head1 DESCRIPTION

TodaysWord::Model::Article

=head1 AUTHOR

marilyn

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

