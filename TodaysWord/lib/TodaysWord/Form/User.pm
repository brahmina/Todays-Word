package TodaysWord::Form::User;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;
use HTML::FormHandlerX::Field::reCAPTCHA;

has '+item_class' => ( default =>'User' );
has_field 'full_name' => (type => 'Text', maxlength => 50, required => 1);
has_field 'email_address' => (type => 'Email', unique => 1, required => 1);
has_field 'username' => (type => 'Text', unique => 1, minlength => 3, maxlength => 20, required => 1);
has_field 'password' => (type => 'Password', minlength => 5, maxlength => 20, required => 1);
has_field 'password_confirm' => ( type => 'PasswordConf', minlength => 5, maxlength => 20, required => 1);


has_field 'Are_you_human' => (
        type=>'reCAPTCHA',
        public_key => '6LfilLsSAAAAAOSAzWIM3YNWx04Zf4kCbuXWTG4J',
        private_key => '6LfilLsSAAAAAOGnopYwt-URv1qBRsKVfkM0_8G_',
        recaptcha_message => "You're failed to prove your Humanity!",
        required => 0,
        recaptcha_options => {theme   => 'blackglass'}
    );

has '+unique_messages' =>
  ( default => sub { { email_address => 'Email address already registered' } } );
has '+unique_messages' =>
  ( default => sub { { username => 'Username address already registered' } } );

has '+name' => ( default =>'signup' );

my $custom_submit = qq~
        <script type="text/javascript">
                var button = '<div class="button" id="submit_signup">'+
                             '<a onclick="submitForm(document.signup)" id="submit_signup_a">'+
                             '<img src="/static/images/icons/agent.png" alt="Sign up" />'+
                             '<span>Sign up</span> </a> </div>'+
                             '<input type="submit" name="hsubmit" class="hidden_submit" /><br />';
                document.write(button);
         </script>                
         <noscript><input type="submit" name="hsubmit" class="submit" value="Submit" /><br /></noscript>
        ~;

has 'custom_submit' => ( isa => 'Str', is => 'rw', default => $custom_submit);

no HTML::FormHandler::Moose;

__PACKAGE__->meta->make_immutable;
1;


