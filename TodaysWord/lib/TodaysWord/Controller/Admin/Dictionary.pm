package TodaysWord::Controller::Admin::Dictionary;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

TodaysWord::Controller::Admin::Dictionary - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

A listing of the available scripts to run on demand

=cut

sub index :Path {
    my ( $self, $c) = @_;

    $c->stash(template => 'admin/dictionary/index.tt');
}

=head2 block_word

=cut

sub block_word :Local {
    my ( $self, $c) = @_;

    my $words = $c->req->param('words');
    if(! $words){
       $c->stash(response => 'Failed: No word sent!');
       $c->stash(template => 'minimal_ajax_reply.tt');
       return;
    }

    my @words;
    if( $words =~ m/,/){
       @words = split(/,/, $words);
    }else{
       @words = ($words);
    }

    my $words_updated = "";
    foreach my $word(@words) {
       $word =~ s/^ +//;
       $word =~ s/ +$//;

       my $dictword = $c->model('DictDB::DictWord')->find({ word => { '=' => $word}});
       if($dictword){
          $dictword->update({'todayswordworthy', 0});
          $words_updated .= $dictword->word .", ";
       }
    }
    $words_updated =~ s/,\s$//;

    $c->stash(template => 'minimal_ajax_reply.tt', response => "Words updated: $words_updated");
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

