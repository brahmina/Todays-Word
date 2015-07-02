package TodaysWord::Fault;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

use Devel::StackTrace;

use Exporter;
my @EXPORT_OK = qw(fault);

=item c

=cut

has 'context' => (is => 'rw', 
                  isa => 'TodaysWord');

=item tech_message

=cut

has 'user_message' => (is => 'rw', 
                       isa => 'Str',
                       default => 'An unknown error occured');

=item tech_message

=cut

has 'tech_message' => (is => 'rw', 
                       isa => 'Str',
                       default => 'Fix me please!');

=item http_status

If present will hyjack the request and send an error page

=cut

has 'http_status' => (is => 'rw', 
                      isa => 'Int',
                      default => 500);

my %http_explanations = ( 400 => 'Bad request',
                          401 => 'Unauthorized',
                          403 => 'Forbidden',
                          404 => 'Not found',
                          500 => 'Unknown error' );

=item throw

Sends the Fault to the error log and the browser

=cut

sub throw {
   my $self = shift;
   my $c = $self->context;
   my ($package, $filename, $line) = caller();
   
   my $fault_message = $self->get_start_of_fault(package => $package, filename => $filename, line => $line);
   my $trace = $self->get_trace();

   # to the error log
   $c->log->error($fault_message."\nMessage: ".$self->tech_message."\n\n".$trace);

   # to the browser
   $c->stash( user_message => $self->user_message );
   $c->stash( http_status => $self->http_status, http_explanation => $http_explanations{$self->http_status} );

   if($c->request->params->{'ajax'}){
      # Don't send a whole page
      $c->stash( template => "error_ajax.tt");
   }else{
      $c->stash( template => "error.tt");
   }
   
   $c->forward("View::TT");
}

=item get_start_of_fault

Returns the top message

=cut

sub get_start_of_fault {
   my $self = shift;
   my %params = @_;
   my $c = $self->context;

   # If we want html error reporting
   my $break = "\n";
   my $space = " ";
   if(0){
      $break = "<br />";
      $space = "&nbsp";
   }
   my $package = $params{'package'};
   my $filename = $params{'filename'};
   my $line = $params{'line'};

   my $start_of_fault_message;
   if($TodaysWord::Setup::DEBUG){
      $start_of_fault_message = "[Error: $package, $line]$break";
   }else{
      my $ip = $c->request->address;
      my $uri = $c->request->uri;
      my $userid = defined($c->user) ? $c->user->id : undef;
      my $date = localtime();
      $start_of_fault_message = "[Error: $ip, $date]".$break."[".($space*7)."$uri]".$break."[".($space*7)."$package, $line]($break*2)";
   }
   return $start_of_fault_message;
}

=item get_trace

Return the trace of the call

=cut

sub get_trace {

   my $trace = Devel::StackTrace->new;
   return $trace->as_string
}

__PACKAGE__->meta->make_immutable;
1;
