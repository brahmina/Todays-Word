package TodaysWord::Controller::Root;

use strict;
use warnings;

use parent 'Catalyst::Controller';

use TodaysWord::Fault;
use TodaysWord::Utilities::Emailer;

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

TodaysWord::Controller::Root - Root Controller for TodaysWord

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 auto

This happens at the start of every request

=cut

sub auto :Global {
   my ( $self, $c ) = @_;

   # Required by some modules
   #     HTML::FormHandlerX::Field::reCAPTCHA
   $ENV{REMOTE_ADDR} = $c->request->address ? $c->request->address : '';
   $ENV{HTTP_REFERER} = $c->request->referer ? $c->request->referer : '';

   # Set the default view
   $c->stash->{current_view} = 'TT';

   # Set up roles in a usable way
   if($c->user_exists){ #defined($c->user)
      $c->stash(user_id => $c->user->id);
      my @user_roles = $c->user->roles;
      foreach my $role(@user_roles) {
         if($role eq "member"){
            $c->stash(user_is_member => 1);
         }
         if($role eq "competitor"){
            $c->stash(user_is_competitor => 1);
         }
         if($role eq "admin"){
            $c->stash(user_is_admin => 1);
         }
      }
   }

   TodaysWord::Model::Hitlog->save_hit($c, $c->{stash}->{user_id});

   $c->log->debug(" Hit to URI: " .$c->request->uri . " from ip '".$c->request->address."'");
   if($c->request->user_agent =~ m/Safari/i){
      $c->stash(browser => 'safari');
      $c->stash->{browser} = 'safari';
   }

   # Block IPs for development
   if(1){
      foreach my $ip(@TodaysWord::Setup::IP) {
         if($c->request->address eq $ip){
            $c->stash->{authorized_ip} = 1;
            $c->stash(authorized_ip => 1);
            return 1;
         }
      }
   }else{
      return 1;
   }

   if(1){
      foreach my $page (keys %TodaysWord::Setup::PERMITTED_PAGES) {
         if($c->request->uri =~ m/$page/ 
               || $c->request->uri eq "http://todays-word.com/" || $c->request->uri eq "http://todays-word.com"
               || $c->request->uri eq "http://www.todays-word.com/" || $c->request->uri eq "http://www.todays-word.com"){
            # The allowed pages during development
            return 1;
         }
      }
      $c->log->debug("redirect to home");
      $c->response->redirect("/");
   }

}

sub playnow :Local {
   my ($self, $c) = @_;
   
   $c->response->redirect("/playnow/1");
}

sub construction :Local {
   my ($self, $c) = @_;
   
   my $word = TodaysWord::Model::DictWord->get_todays_word($c);
   $c->stash(todaysword => $word->word);   
   $c->stash(template => 'construction.tt');
}

sub contact :Local { 
   my ($self, $c) = @_;

   $c->log->debug(" in contact with: " . $c->request->params->{'message'});

   if($c->request->params->{'message'}){
      $c->log->debug(" -> got message " . $c->request->params->{'message'});
      
      # Save the feedback & Send email to admin
      TodaysWord::Utilities::Emailer->send_feedback_received_email($c);

      $c->stash(feedback_received => 1);
      $c->stash(in_addition => $c->request->params->{'ajax'});
   }

   if($c->request->params->{'ajax'}){
      $c->stash(template => 'feedback_form.tt');
   }else{
      $c->stash(template => 'contact.tt');
   }
}

sub about :Global {
   my ( $self, $c ) = @_;

   $c->stash(template => 'about.tt');

}


sub account :Global {
   my ( $self, $c ) = @_;

   if($c->user_exists){ #defined($c->user)
      $c->stash(template => 'account.tt');
   }else{      
      $c->response->redirect('/auth/login');
   }

}

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

   my $word = TodaysWord::Model::DictWord->get_todays_word($c);
   $c->stash(todaysword => $word);   

   # For the playnow index, category listing 
   my $categories = TodaysWord::Model::Category->get_all_releasable_categories($c);
   
   # This is the 'Word Games to Play Online' article for the copy on the playnow page
   my $meta_description = "TODO";
   my $meta_keywords = TodaysWord::Model::Keyword->get_keywords_for_item($c, table => 'article', table_id => 4);

   my $highest_rated_playnow_games = TodaysWord::Model::Playnow->get_highest_rated_games($c);

   $c->stash(template => 'index.tt', categories => $categories, highest_rated_playnow_games => $highest_rated_playnow_games,
               meta_keywords => $meta_keywords, meta_description => $meta_description);

    # Hello World
    #$c->response->body( $c->welcome_message );
}

sub default :Path {
    my ( $self, $c ) = @_;

    $c->log->debug("in default");

    if(! $c->stash->{authorized_ip}){
       $c->response->redirect("/construction");
    }else{
       # Coolio 404 page
       TodaysWord::Fault->new(context => $c, 
                              http_status => 404,
                              user_message => "The page requested cannot be found")->throw();
    }
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
   my ( $self, $c ) = @_;

   #TodaysWord::Model::Advert->process_template($c);
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;


