#!/usr/bin/perl

use strict;
#use warnings;

use WWW::Mechanize;

my $mech = new WWW::Mechanize;

$mech->get( 'http://todays-word.com/auth/login' );

#print "Content of login page: \n".$mech->content()."\n";

$mech->submit_form(
    form_name => 'login',
    fields      => {
        username => 'marilyn',
        password => 'benny78',
    }
);

$mech->get( 'http://todays-word.com/admin/scripts/send_future_todays_words_email' );

#print "Content of login page: \n".$mech->content()."\n";

print "cya\n";




