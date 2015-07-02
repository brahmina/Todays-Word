package TodaysWord::Controller::Admin::Games::TodaysWord;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use TodaysWord::Form::TodaysWord;
use TodaysWord::Model::TodaysWord;
use TodaysWord::Model::DailyGame;

=head1 NAME

TodaysWord::Controller::Admin::Games::TodaysWord - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 all

=cut

sub all :Local {
    my ( $self, $c) = @_;

    my @todayswords = $c->model('DB')->resultset('TodaysWord')->search({
         scheduled_date => { '=', undef }
    });

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $self->stash_calendar($c, $mon+1, $year+1900);

    $c->stash(template => 'admin/games/todaysword/todayswords.tt', todayswords => \@todayswords);
}

=head2 index

=cut

sub index :Path :Args(2) {
    my ( $self, $c, $month, $year ) = @_;


    $c->log->debug("month: $month, year: $year");

    my @todayswords = $c->model('DB')->resultset('TodaysWord')->search({
         scheduled_date => { '=', undef }
    });

    $self->stash_calendar($c, $month, $year);

    $c->stash(template => 'admin/games/todaysword/todayswords.tt', todayswords => \@todayswords);
}

=head2 stash_calendar

=cut

sub stash_calendar {
    my ( $self, $c, $month, $year ) = @_;

    use TodaysWord::Utilities::DailyCalendar;
    my $DailyCalendar = new TodaysWord::Utilities::DailyCalendar();
    my $calendarHTML = $DailyCalendar->getCalendarHTML($c, $month, $year, 'todaysword');

    $c->stash(calendar => $calendarHTML);
}

=head2 show

=cut

sub show :Local {
    my ($self, $c, $id) = @_;

    my $todaysword = $c->model('DB::TodaysWord')->find({id => $id});
    my $word = $c->model('DictDB::DictWord')->find({id => $todaysword->dict_word_id});
    TodaysWord::Model::TodaysWord->process_word($c, $word);

    my $date = "Not scheduled";
    my $daily_game = $c->model('DB')->resultset('DailyGame')->search({
            game_table => { '=', 'todaysword' },
            game_id => {'=', $id}
       })->single();

    if($daily_game){
       $date = $daily_game->play_date;
    }

    # Inclue the words and definitions for helping with clues
    $c->stash( template => 'admin/games/todaysword/todaysword.tt', id => $id, todaysword => $todaysword, word => $word, date => $date);
}


=head2 set_play_date

=cut

sub set_play_date :Local {
    my ($self, $c, $todaysword_id) = @_;

    # Temp for ajax loader testing
    my $waittime = time() + 0;
    while (time() < $waittime) {}

    my $todaysword = $c->model('DB::TodaysWord')->find({id => $todaysword_id});
    my $date = TodaysWord::Model::DailyGame->set_play_date($c, $c->req->param('the_play_date'), 'todaysword', $todaysword);


    if($c->req->param('ajax')){
       $c->stash( template => 'admin/games/todaysword/set_play_date.tt', date => $date, todaysword => $todaysword, isAjax => 1);
    }else{
       $self->show($c, $todaysword_id);
    }
}


=head2 add

=cut

sub add :Local {
    my ( $self, $c ) = @_;

    my ($form, $error_message) = $self->form($c);

    # 5 random words from dict_word, with definitions, frequency, clues
    my @word_ids;
    for(1 .. 25){
       push(@word_ids, sprintf("%d", rand($TodaysWord::Setup::TW_MAX_DICT_WORD_ID)) );
    }

    my @words = $c->model('DictDB')->resultset('DictWord')->search({
         id => { 'in', \@word_ids }
    });

    use Data::Dumper;
    $c->log->debug("***  word_ids: @word_ids");

    foreach my $word(@words) {
       $c->log->debug("*** word: " . $word->word);
       TodaysWord::Model::TodaysWord->process_word($c, $word);
    }

    $c->log->debug("words: @words");

    $c->stash( template => 'admin/games/todaysword/add_todaysword.tt', words => \@words, form => $form);
}

=head2 form

Process the FormHandler crossword form

=cut

sub form {
   my ( $self, $c ) = @_;

   my $form = TodaysWord::Form::TodaysWord->new;

   my $todaysword;
   my $error_message = "";
   if($c->request->params->{'word'}){

      my $valid = 1;
      if(! $c->request->params->{'word'}){
         $valid = 0;
      }
      # Validate the input
      if($valid){
         my $time = time();
         my $dict_word = $c->model('DictDB')->resultset('DictWord')->search({
               word => { '=', $c->req->param('word') }
         })->single();
         my $dict_word_id;
         if($dict_word){
            $dict_word_id = $dict_word->id;
         }
         $todaysword = $c->model('DB::TodaysWord')->find_or_create({
                                    word => $c->req->param('word'),
                                    clue1 => $c->req->param('clue1'),
                                    clue2 => $c->req->param('clue2'),
                                    clue3 => $c->req->param('clue3'),
                                    clue4 => $c->req->param('clue4'),
                                    clue5 => $c->req->param('clue5'),
                                    create_date => $time,
                                    dict_word_id => $dict_word_id
                    });


         # Redirect the user back to the list page
         $c->response->redirect("/admin/games/todaysword/show/".$todaysword->id);
      }else{
         $error_message = "Missing fields!";
         return $form, $error_message;
         #$c->stash( template => 'admin/games/crossword/add_todaysword.tt', form => $form, error_message => $error_message );
      }
   }else{
      return $form, $error_message;
      # Set the template
      $c->stash( template => 'admin/games/crossword/add_todaysword.tt', form => $form, error_message => $error_message );
   }
}

=head2 edit

=cut

sub edit :Local {
    my ( $self, $c, $todaysword_id ) = @_;

    if($todaysword_id){
       my $todaysword = $c->model('DB::TodaysWord')->find({id => $todaysword_id});

       $c->log->debug("todaysword: $todaysword -> " . $todaysword->word );

       my @fields = qw(word clue1 clue2 clue3 clue4 clue5);
       foreach my $field(@fields) {
          if($todaysword->word ne $field){
             $todaysword->update({ $field => $c->req->param($field)});

             if($field eq 'word'){
                my $dict_word = $c->model('DictDB')->resultset('DictWord')->search({
                     word => { '=', $c->req->param('word') }
                })->single();
                if($dict_word){
                   $todaysword->update({ 'dict_word_id' => $dict_word->id });
                }else{
                   $todaysword->update({ 'dict_word_id' => undef });
                }
             }
          }
       }
    }

    $c->response->redirect("/admin/games/todaysword/show/$todaysword_id");
}

=head2 delete

=cut

sub delete :Local {
    my ( $self, $c, $todaysword_id ) = @_;

    if($todaysword_id){
       $c->model('DB::TodaysWord')->find({id => $todaysword_id})->delete;
    }

    $c->response->redirect("/admin/games/todaysword/all/");
}


=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;



