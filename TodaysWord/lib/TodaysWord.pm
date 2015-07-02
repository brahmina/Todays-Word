package TodaysWord;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

use TodaysWord::Setup;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory


# 
use Catalyst qw/
     -Debug
      ConfigLoader
      Static::Simple
      
      StackTrace

      Authentication

      Session::DynamicExpiry
      Session
      Session::Store::DBI
      Session::State::Cookie
/;

#Session::DynamicExpiry

extends 'Catalyst';

our $VERSION = '0.01';
$VERSION = eval $VERSION;

if($TodaysWord::Setup::DEBUG && 0){
   $ENV{DBIC_TRACE}++;
}


# Configure the application.
#
# Note that settings in todaysword.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'TodaysWord',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
);

__PACKAGE__->config('Plugin::Session' => {
        expires   => $TodaysWord::Setup::SESSION_EXPIRY,
        dbi_dsn   => 'dbi:mysql:TodaysWord',
        dbi_user  => 'crosswordy',
        dbi_pass  => 'wordsarethebest8392',
        dbi_table => 'sessions',
        dbi_id_field => 'id',
        dbi_data_field => 'session_data',
        dbi_expires_field => 'expires',
});

__PACKAGE__->config->{'View::Email::Template'} = {
    template_prefix =>  'emails',
    stash_key       =>  'email_template',
    default =>  {
        view            =>  'TT',
        content_type    =>  'text/plain',
        charset         =>  'utf-8',
    },
    sender  =>  {
        mailer      =>  'SMTP',
        mailer_args =>  {
            host            =>  'smtp.gmail.com',
            port            =>  465,
            sasl_username   =>  'brahmina@brahminacreations.com',
            sasl_password   =>  'BrahmanLove8Abundance69',
            ssl             =>  1,
        }
    },
};


__PACKAGE__->config({
    
      'View::JSON' => {
         # allow_callback  => 1,    # defaults to 0
         # callback_param  => 'cb', # defaults to 'callback'
          expose_stash    => [ qw( keywords ) ], # defaults to everything
    },
});

__PACKAGE__->config(
        'View::Email' => {
            stash_key => 'email',
            default => {
                content_type => 'text/html',
                charset => 'utf-8'
            },
            sender => {
                mailer => 'SMTP',
                mailer_args =>  {
                   host            =>  'smtp.gmail.com',
                   port     => 465,
                   sasl_username   =>  'brahmina@brahminacreations.com',
                   sasl_password   =>  'BrahmanLove8Abundance69',
                   ssl             =>  1,
               }
            }
        }
    );

__PACKAGE__->config(
    authentication => {
        default_realm => 'users',
        realms => {
            users => {
                credential => {
                    class => 'Password',
                    password_field => 'password',
                    password_type => 'self_check',
                },
                store => {
                    class => 'DBIx::Class',
                    user_model => 'DB::User',
                    role_relation => 'roles',
                    role_field => 'role',
                    use_userdata_from_session => 1,
                },
            },
        }
    }
);

# Start the application
__PACKAGE__->setup();


=head1 NAME

TodaysWord - Catalyst based application

=head1 SYNOPSIS

    script/todaysword_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<TodaysWord::Controller::Root>, L<Catalyst>

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;


