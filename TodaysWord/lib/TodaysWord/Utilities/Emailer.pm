package TodaysWord::Utilities::Emailer;
use Moose;
use namespace::autoclean;

use TodaysWord::Setup;
use TodaysWord::Utilities::Date;

=head1 NAME

TodaysWord::Utilities::Emailer 

=head1 DESCRIPTION

Emailer method wrapper

=head1 METHODS

=head2 send_future_todays_words_email

Sends the administrator the next X Today's Words for review

=cut

sub send_future_todays_words_email {
   my ($self, $c) = @_;

   $c->log->debug("in send_feedback_received_email, sending to $TodaysWord::Setup::ADMIN_EMAIL_ADDRESS");

   my @future_words; my $at_midnight;
   my $DateUtility = new TodaysWord::Utilities::Date();
   foreach my $days (0..7){
      $at_midnight = $DateUtility->getDayAtMidnight($c, (time()-(60*60*5))+(60*60*24*$days) );
      $c->log->debug("Seed: $at_midnight");
      my $word = TodaysWord::Model::DictWord->get_word($c, seed => $at_midnight, todayswordworthy => 1);
      $word->{date} = TodaysWord::Utilities::Date::getBriefHumanFriendlyDate($at_midnight);
      push(@future_words, $word);
   }
   $c->stash->{future_words} = \@future_words;

   $c->stash->{email_template} = {
            to      => $TodaysWord::Setup::ADMIN_EMAIL_ADDRESS,
            from    => $TodaysWord::Setup::FROM_EMAIL_ADDRESS,
            subject => "Future Today' Words",
            templates => [
                    {
                        template        => 'future_todays_words.html.tt',
                        content_type    => 'text/html',
                        charset         => 'utf-8',
                        encoding        => 'quoted-printable',
                        view            => 'TT', 
                    },
                    {
                        template        => 'future_todays_words.txt.tt',
                        content_type    => 'text/plain',
                        charset         => 'utf-8',
                        encoding        => 'quoted-printable',
                        view            => 'TT', 
                    } 
                    ]
   };
   $c->forward( $c->view('Email::Template'));
}

=head2 send_to_a_friend_email

Sends the 'send to a friend email'

=cut

sub send_to_a_friend_email {
   my ($self, $c) = @_;

   $c->log->debug("in send_to_a_friend_email, sending to ".$c->req->param('to'));

   $c->stash->{email_template} = {
            to      => $c->req->param('to'),
            from    => $TodaysWord::Setup::FROM_EMAIL_ADDRESS,
            subject => "A link from Today's Word",
            templates => [
                    {
                        template        => 'send_to_a_friend.html.tt',
                        content_type    => 'text/html',
                        charset         => 'utf-8',
                        encoding        => 'quoted-printable',
                        view            => 'TT', 
                    },
                    {
                        template        => 'send_to_a_friend.txt.tt',
                        content_type    => 'text/plain',
                        charset         => 'utf-8',
                        encoding        => 'quoted-printable',
                        view            => 'TT', 
                    } ]
   };
   $c->forward( $c->view('Email::Template'));
}


=head2 send_feedback_received_email

Sends the feedback to the admin email address. Also saves the feedback info in the database

=cut

sub send_feedback_received_email {
   my ($self, $c) = @_;

   $c->log->debug("in send_feedback_received_email, sending to $TodaysWord::Setup::ADMIN_EMAIL_ADDRESS");

   my $template;
   my $message = $c->request->params->{'message'};
   my $email_valid = 1; # TODO -> test for email validity
   if($message){
      my $feedback = $c->model('DB::Feedback')->find_or_create({
                                          email => $c->request->params->{'email'},
                                          message => $c->request->params->{'message'},
                                          ip => $c->request->address,
                                          user_id => $c->{stash}->{user_id},
                                          create_date => time()
                                   });
      $c->stash->{feedback} = $feedback;
      $c->stash->{email_template} = {
               to      => $TodaysWord::Setup::ADMIN_EMAIL_ADDRESS,
               from    => $TodaysWord::Setup::FROM_EMAIL_ADDRESS,
               subject => "Feedback from Today's Word",
               template=> 'feedback_received.tt'

      };
      if($c->request->params->{'email'}){
         $c->stash->{email_template}->{reply_to} = $c->request->params->{'email'};
      }
      $c->forward( $c->view('Email::Template'));
   }
}

=head1 AUTHOR

Marilyn

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;


