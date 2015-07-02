package TodaysWord::Model::Hitlog;

use strict;

=head2 save_hit

=cut

sub save_hit {
   my ($self, $c, $user_id) = @_;

   my $hit = $c->model('DB::Hitlog')->create({
                                    user_id => $user_id,
                                    url => $c->request->uri,
                                    ip => $c->request->address ? $c->request->address : '',
                                    referrer => $c->request->referer ? $c->request->referer : '',
                                    user_agent => $c->request->user_agent,
                                    create_date => time
                    });
}


=head1 NAME

ord::Model::Hitlog09

=head1 SYNOPSIS

See L<TodaysWord>

=head1 DESCRIPTION

TodaysWord::Model::Hitlog

=head1 AUTHOR

marilyn

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

