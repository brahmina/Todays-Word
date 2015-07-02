package TodaysWord::Utilities::SocialButtons;
use Moose;
use namespace::autoclean;

=head1 NAME

TodaysWord::Utilities::SocialButtons 

=head1 DESCRIPTION

Supported:

* digg
* facebook
* twitter
* delicious
* stumbleupon
* email - todo
* reddit

=cut

my $DIGG = qq~<script type="text/javascript">(function() {var s = document.createElement('SCRIPT'), s1 = document.getElementsByTagName('SCRIPT')[0];s.type = 'text/javascript';s.async = true;s.src = 'http://widgets.digg.com/buttons.js';s1.parentNode.insertBefore(s, s1);})();</script><a class="DiggThisButton DiggIcon"></a>~;
my $FACEBOOK = qq~<script type="text/javascript">function fbs_click() {u=location.href; t=document.title;window.open('http://www.facebook.com/sharer.php?u='+encodeURIComponent(u)+'&amp;t='+encodeURIComponent(t),'sharer','toolbar=0,status=0,width=626,height=436');return false;}</script><a href="http://www.facebook.com/share.php?u=the_url" onclick="return fbs_click()" target="_blank"><img src="http://b.static.ak.fbcdn.net/images/share/facebook_share_icon.gif?8:26981" width="16" height="16" alt="Share" /></a>~;
my $STUMBLEUPON = qq~<a href="http://www.stumbleupon.com/submit?url=the_url&amp;title=the_title" target="_new"> <img border="0" src="http://cdn.stumble-upon.com/images/32x32_su_round.gif" width="16" height="16" alt="Stumble" /></a>~;
my $TWITTER = qq~<a href="http://twitter.com/home?status=the_title the_url" target="_new"><img src="http://twitter.com/images/favicon.png" width="16" height="16" alt="Tweet" /></a>~;
my $DELICIOUS = qq~<a href="http://delicious.com/save" onclick="window.open('http://delicious.com/save?v=5&amp;noui&amp;jump=close&amp;url='+encodeURIComponent(location.href)+'&amp;title='+encodeURIComponent(document.title), 'delicious','toolbar=no,width=550,height=550'); return false;"> <img src="http://static.delicious.com/img/delicious.gif" alt="Delicious" width="16" height="16" /></a>~;
my $EMAIL = qq~<a href="/send_to_a_friend" id="send_to_a_friend"><img src="/static/images/email_social.png" alt="Sent to a friend" width="16" height="16" /></a>~;
my $REDDIT = qq~<a href="http://www.reddit.com/submit" onclick="window.location = 'http://www.reddit.com/submit?url=' + encodeURIComponent(window.location); return false"> <img src="http://www.reddit.com/static/spreddit5.gif" alt="submit to reddit" border="0" /> </a>~;

=head1 METHODS

=cut

=item get_social_buttons

=cut

sub get_social_buttons {
   my ( $self, $c, %params ) = @_;

   my $social_buttons = "";

   my $buttons_needed;
   if($params{buttons_needed}){
      $buttons_needed = $params{buttons_needed};
   }else{
      $buttons_needed = { #'digg' => $DIGG,
                          'facebook' =>  $FACEBOOK,
                          'stumbleupon' => $STUMBLEUPON,
                          'twitter' => $TWITTER,
                          #'delicious' => $DELICIOUS,
                          'reddit' => $REDDIT,
                          'email' => $EMAIL# TODO -> implement email to a friend at /tell_a_friend
                          };
   }

   my $button; 
   foreach my $k(sort keys %{$buttons_needed}) {
      
      $button = $buttons_needed->{$k}."\n";
      $button =~ s/the_title/$params{title}/;
      $button =~ s/the_url/$params{url}/;

      $social_buttons .= "<li>".$button."</li>"; 
   }

   return "<ul>".$social_buttons."</ul>";

}

__PACKAGE__->meta->make_immutable;

1;



