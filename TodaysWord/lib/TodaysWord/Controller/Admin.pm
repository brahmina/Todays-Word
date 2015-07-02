package TodaysWord::Controller::Admin;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

TodaysWord::Controller::Admin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

=head2 auto

Check if there is a user and, if not, forward to login page

=cut

# Note that 'auto' runs after 'begin' but before your actions and that
# 'auto's "chain" (all from application path to most specific class are run)
# See the 'Actions' section of 'Catalyst::Manual::Intro' for more info.
sub auto :Private {
   my ($self, $c) = @_;

   # Allow unauthenticated users to reach the login page.  This
   # allows unauthenticated users to reach any action in the Login
   # controller.  To lock it down to a single action, we could use:
   #   if ($c->action eq $c->controller('Login')->action_for('index'))
   # to only allow unauthenticated access to the 'index' action we
   # added above.

   # Block IPs for development
   my $authorized_ip = 0;
   foreach my $ip(@TodaysWord::Setup::IP) {
      if($c->request->address eq $ip){
         $c->stash->{authorized_ip} = 1;
         $c->stash(authorized_ip => 1);
         $authorized_ip = 1;
      }
   }
   if(! $authorized_ip){
      $c->response->redirect("/construction");
   }

   # If a user doesn't exist, force login
   if ($c->user_exists && $c->stash->{user_is_admin}) {

      # Set the admin section to get the right header bar
      my $uri = $c->request->uri;
      if($uri =~ m/printablecrosswords/){
         $c->stash(admin_section => 'printablecrosswords');
      }elsif($uri =~ m/wordgamestoday/){
         $c->stash(admin_section => 'wordgamestoday');
      }else{
         $c->stash(admin_section => 'todaysword');
      }

      return 1;
   }else{
      $c->stash(template => 'admin/denied.tt', user_message => "");
      return 0;
   }
}

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(template => 'admin/index.tt', user_message => "  ");
}

sub todo :Local { # Should be in admin
   my ($self, $c) = @_;
   
   $c->stash(template => 'todo.tt');
}
sub images :Local { # Should be in admin
   my ($self, $c) = @_;

   $c->stash(template => 'images.tt');
}

sub testing :Local { # Should be in admin
   my ( $self, $c) = @_;

   $c->stash(template => 'testing.tt');
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;




