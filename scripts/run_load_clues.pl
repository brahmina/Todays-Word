#!/usr/bin/perl

use strict;

# Runs only once because load_clues is so slow
my $start_time = time();
`perl /home/www-data/todays-word.com/scripts/load_dictionary.pl`;
my $done_dictionary_time = time();
`perl /home/www-data/todays-word.com/scripts/load_clues.pl`;
my $done_clues_time = time();
`perl /home/www-data/todays-word.com/scripts/clean_clues.pl`;
my $end_time = time();

send_confirmation_email();

sub send_confirmation_email{

    my $sendmail = "/usr/sbin/sendmail -t";
    my $send_to = 'To: marilyn@marilynburgess.com\n';
    my $send_from = 'From: server@go-list-yourself.com\n';
    my $reply_to = 'Reply-to: marilyn@marilynburgess.com\n';
    my $subject = "Subject: Ran load clues!\n";
    my $content = qq~Start time: $start_time
End time: $end_time
Done dictionary time: $done_dictionary_time
Done clues time: $done_clues_time
End time: $end_time

Verify that script ran right, and remove from cron.~;

    open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
    print SENDMAIL $send_to;
    print SENDMAIL $send_from;
    print SENDMAIL $reply_to;
    print SENDMAIL $subject;
    print SENDMAIL $content;
    close(SENDMAIL);
}

