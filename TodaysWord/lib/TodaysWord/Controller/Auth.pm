package TodaysWord::Controller::Auth;
use Moose;
use namespace::autoclean;
BEGIN {extends 'Catalyst::Controller'; }

use Crypt::Eksblowfish::Bcrypt qw(bcrypt_hash);
use TodaysWord::Form::User;

=head1 NAME

TodaysWord::Controller::Auth - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller to handle signup, login, logout and forgot password stuff

=head1 METHODS

=cut


=head2 index

If logged in, redirect to account, with msg -> You are logged in

Else, redirect to /auth/login

=cut

sub index :Local {
   my ($self, $c) = @_;

   if($c->user_exists){
      $c->response->redirect("/account");
   }else{
      $c->response->redirect("/auth/login");
   }
}

=head2 login

Login page

=cut

sub login :Local :Path {
   my ($self, $c) = @_;

   if($c->user_exists()){ # defined($c->user)
      $c->response->redirect("/account");

      # TODO -> take user backto where they were on login
      # $c->session->{login_back} = $c->req->uri
      # unless ($c->action =~ /^(login|logout|rest\/)/ || $c->action eq '/');
      # then
      # $c->response->redirect( delete $c->session->{login_back} || $c->uri_for_action('/index') );

   }
   # If submit
   if(defined($c->request->params->{'username'})){
      # Get the username and password from form
      my $username = $c->request->params->{username};
      my $password = $c->request->params->{password};
      if ($username && $password) {
         # Attempt to log the user in
         if ( $c->authenticate({ username => $username, password => $password })) {

            # Persistent cookies
            if ($c->request->params->{'remember'}) {
               $c->log->debug("Setting remember me: $BackMouse::Setup::REMEMBER_ME_EXPIRY");
               $c->session_time_to_live( $BackMouse::Setup::REMEMBER_ME_EXPIRY );
            }

            $c->response->redirect('/');

            # TODO - Track logins
            return;
         } else {
             $c->stash(error_message => "Bad username or password.");
         }
      }else{
         $c->stash(error_message => "Empty username or password.");
      }
   }

   # If no submit, or failed login, send to the login page
   $c->stash(template => 'auth/login.tt');
}

=head2 forgot_password

The forgot password function

=cut

sub forgot_password :Local {
   my ($self, $c) = @_;

   my $template;
   if($c->request->params->{'p1'} 
      && $c->request->params->{'i'} && $c->request->params->{'e'} && $c->request->params->{'t'}){
      # Resetting the password
      $template = $self->change_password($c);
   }elsif($c->request->params->{'i'} && $c->request->params->{'e'} && $c->request->params->{'t'}){
      # user clicked on the link from the email, verify the data
      # e -> email, t -> token, i -> id for the tocken
      $template = $self->verify_reset_password_request($c);
   }elsif($c->request->params->{'email'}){
      # Send the reset email password
      $template = $self->send_password_reset_email($c);
   }else{
      # If no submit, send to the send reset password email page
      $template = 'auth/forgot_password.tt';
   }

   $c->stash(template => $template);
}

=head2 send_password_reset_email

Changes the password if the 2 match, returns the template to send back to the user

=cut

sub send_password_reset_email {
   my ($self, $c) = @_;

   my $template;
   my $email = $c->request->params->{'email'};
   my $email_valid = 1; # TODO -> test for email validity
   if($email && $email_valid){
      my $user = $c->model('DB::User')->find({email_address => $email});
      if($user->id){
         # The email belongs to a user, send the email
         my $token = $self->generate_token($c);
         my $pass_reset_info = $c->model('DB::PasswordResetInfo')->create({
                                             email => $email,
                                             token => $token,
                                             date => time(),
                                             used => 0
                                      });

         $c->stash->{reset_link} = $TodaysWord::Setup::URL . "/auth/forgot_password/?t=$token&e=$email&i=".$pass_reset_info->id;

         $c->stash->{email_template} = {
               to      => $email,
               from    => $TodaysWord::Setup::FROM_EMAIL_ADDRESS,
               subject => 'Today\'s Word password reset',
               template=> 'reset_password.tt'

         };

         $c->forward( $c->view('Email::Template'));
         if ( scalar( @{ $c->error } ) ) {
            $c->stash(error_message => 'Email sending failed, please try again later');
            $template = 'auth/email_not_sent.tt';
         }else {
            $c->stash(error_message => 'Email sent!');
            $template = 'auth/email_sent.tt';
         }
      }else{
         # No user found
         $template = 'auth/no_user_found.tt';
      }

   }else{
      $template = 'auth/forgot_password.tt';
      $c->stash(error_message => "Email not found");
   }
   return $template;
}


=head2 change_password

Changes the password if the 2 match, returns the template to send back to the user

=cut

sub change_password {
   my ($self, $c) = @_;

   # e -> email
   # t -> token
   # i -> id for the tocken

   my $template;
   if($c->request->params->{'p1'} eq $c->request->params->{'p2'}){
      # Check the token again
      my $password_reset_info = $c->model('DB::PasswordResetInfo')->find({id => $c->request->params->{'i'}});
      if($c->request->params->{'t'} eq $password_reset_info->token && $c->request->params->{'e'} eq $password_reset_info->email){
         # Change the password
         #my $hashed_password = bcrypt_hash({key_nul => 1, cost => 8,}, $c->request->params->{'p1'});

         my $user = $c->model('DB::User')->find({email_address => $password_reset_info->email});
         $user->update({'password' => $c->request->params->{'p1'}});

         $template = 'auth/reset_password_success.tt';
         $password_reset_info->update({used => 1});
      }else{
         # Failed the test, cannot reset
         $template = 'auth/failed_password_reset.tt';
         $c->stash(error_message => "Your password could not be reset.");
      }
   }else{
      $template = 'auth/reset_password.tt';
      $c->stash(error_message => "Passwords do not match.");
   }
   return $template;
}

=head2 verify_reset_password_request

Verrifies the info from the reset password link clicked  by the user from their email is valid

=cut

sub verify_reset_password_request {
   my ($self, $c) = @_;

   # e -> email
   # t -> token
   # i -> id for the tocken
   my $template;
   my $password_reset_info = $c->model('DB::PasswordResetInfo')->find({id => $c->request->params->{'i'}});
   if($c->request->params->{'t'} eq $password_reset_info->token && $c->request->params->{'e'} eq $password_reset_info->email){
      # Present the new password form
      $c->stash(t => $password_reset_info->token, e => $password_reset_info->email, i => $c->request->params->{'i'});
      $template = 'auth/reset_password.tt';
   }else{
      # Failed the test, cannot reset
      $template = 'auth/failed_password_reset.tt';
   }
   return $template;
}

=head2 generate_token

Generates the token used to verify a forgot password request

=cut

sub generate_token {
   my ($self, $c) = @_;

   my $token;
   my $_rand;

   my @chars = split(" ", "a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z - _ 0 1 2 3 4 5 6 7 8 9");
   srand;

   for (my $i=0; $i < $TodaysWord::Setup::PASSWORD_RESET_TOKEN_LENGTH ;$i++) {
      $_rand = int(rand scalar(@chars));
      $token .= $chars[$_rand];
   }
   return $token;
}

=head2 signup

Use HTML::FormHandler to create a new user

=cut

sub signup :Local Chained('base') PathPart('create') {
   my ($self, $c ) = @_;

   my $user = $c->model('DB::User')->new_result({});
   my $form = $self->signup_form($c, $user);
   return $form;
}

=head2 form

Process the FormHandler book form

=cut

sub signup_form {
   my ( $self, $c, $user ) = @_;

   my $form = TodaysWord::Form::User->new;
   # Set the template
   $c->stash( template => 'auth/signup.tt', form => $form );

   # TODO - fix signup & login
   $form->process( item => $user, params => $c->req->params );

   return unless $form->validated;

   my $user_role = $c->model('DB::UserRole')->create( {role_id => 2, # user
                                                       user_id => $user->id });


   # TODO -> Ensure this goes somewhere proper on success
   if($c->authenticate({ username => $c->request->params->{username}, password => $c->request->params->{password}})){
      #$c->flash( message => 'Sucessfully signed up' );
      # Redirect the user back to the list page
      $c->response->redirect("/");
   }else{
      $c->log->debug( message => "Could not authernticate username => ".$c->request->params->{username} );
      $c->stash( error_message => "Could not authenticate");
      $c->stash( template => 'auth/signup.tt', form => $form );
   }
}

=head2 logout

Logout logic

=cut

sub logout :Local {
   my ($self, $c) = @_;

   # Clear the user's state
   $c->logout;

   # Send the user to the starting point
   $c->response->redirect($c->uri_for('/'));
}



=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

