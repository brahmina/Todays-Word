package TodaysWord::Controller::Admin::Games::Acro;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use TodaysWord::Form::Acro;
use TodaysWord::Model::DailyGame;

=head1 NAME

TodaysWord::Controller::Admin::Games::Acro - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 all

=cut

sub all :Local {
    my ( $self, $c) = @_;

    my @acros = $c->model('DB')->resultset('Acro')->search({
         scheduled_date => { '=', undef }
    });

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $self->stash_calendar($c, $mon+1, $year+1900);

    $c->stash(template => 'admin/games/acro/acros.tt', acros => \@acros);
}

=head2 index

=cut

sub index :Path :Args(2) {
    my ( $self, $c, $month, $year ) = @_;


    $c->log->debug("month: $month, year: $year");

    my @acros = $c->model('DB')->resultset('Acro')->search({
         scheduled_date => { '=', undef }
    });

    $self->stash_calendar($c, $month, $year);

    $c->stash(template => 'admin/games/acro/acros.tt', acros => \@acros);
}

=head2 stash_calendar

=cut

sub stash_calendar {
    my ( $self, $c, $month, $year ) = @_;

    use TodaysWord::Utilities::DailyCalendar;
    my $DailyCalendar = new TodaysWord::Utilities::DailyCalendar();
    my $calendarHTML = $DailyCalendar->getCalendarHTML($c, $month, $year, 'acro');

    $c->stash(calendar => $calendarHTML);
}

=head2 show

=cut

sub show :Local {
    my ($self, $c, $id) = @_;

    my $acro = $c->model('DB::Acro')->find({id => $id});

    my $date = "Not scheduled";
    my $daily_game = $c->model('DB')->resultset('DailyGame')->search({
            game_table => { '=', 'acro' },
            game_id => {'=', $id}
       })->single();

    if($daily_game){
       $date = $daily_game->play_date;
    }

    # Inclue the words and definitions for helping with clues
    $c->stash( template => 'admin/games/acro/acro.tt', id => $id, acro => $acro, date => $date);
}


=head2 set_play_date

=cut

sub set_play_date :Local {
    my ($self, $c, $acro_id) = @_;

    # Temp for ajax loader testing
    my $waittime = time() + 0;
    while (time() < $waittime) {}

    my $acro = $c->model('DB::Acro')->find({id => $acro_id});
    my $date = TodaysWord::Model::DailyGame->set_play_date($c, $c->req->param('the_play_date'), 'acro', $acro);

    if($c->req->param('ajax')){
       $c->stash( template => 'admin/games/acro/set_play_date.tt', date => $date, acro => $acro, isAjax => 1);
    }else{
       $self->show($c, $acro_id);
    }
}


=head2 add

=cut

sub add :Local {
    my ( $self, $c ) = @_;

    my $form = $self->form($c);
    return $form;
}


=head2 form

Process the FormHandler Acro form

=cut

sub form {
   my ( $self, $c ) = @_;

   my $form = TodaysWord::Form::Acro->new;

   foreach my $p($c->req->params()) {
      $c->log->debug("param: $p : " . $c->req->param($p));
   }

   my $acro;
   my $error_message = "";
   if($c->req->param('number_of_letters')){

      my $valid = 0;
      if($c->req->param('number_of_letters') !~ m/\D+/){
         $valid = 1;
      }
      # Validate the input
      if($valid){
         my $time = time();

         my $letters = $self->get_acro_starting_letters($c, $c->req->param('number_of_letters'));

         $acro = $c->model('DB::Acro')->find_or_create({
                                          letters => $letters,
                                          create_date => $time
                    });

         $c->response->redirect("/admin/games/acro/show/".$acro->id);
      }else{
         $error_message = "Only digits in the Number of Letters field!";
         $c->stash( template => 'admin/games/acro/add_acro.tt', form => $form, error_message => $error_message, acro => $acro );
      }
   }else{
      $c->stash( template => 'admin/games/acro/add_acro.tt', form => $form, error_message => $error_message, acro => $acro );
   }
}

=head2 change_letters

=cut

sub change_letters :Local {
    my ( $self, $c, $acro_id ) = @_;

    if($acro_id){
       my $acro = $c->model('DB::Acro')->find({id => $acro_id});

       my $letters = $c->req->param('letters');
       if($c->req->param('letters') eq $acro->letters){
          my @ltrs = split(" ", $letters);
          $letters = $self->get_acro_starting_letters($c, scalar(@ltrs));
       }

       $letters = uc($letters);
       $acro->update({letters => $letters});
    }

    $c->response->redirect("/admin/games/acro/show/$acro_id");
}


=head2 delete

=cut

sub delete :Local {
    my ( $self, $c, $acro_id ) = @_;

    if($acro_id){
       $c->model('DB::Acro')->find({id => $acro_id})->delete;
       $c->model('DB::AcroPhrase')->search({ acro_id => $acro_id })->delete;
    }

    $c->response->redirect("/admin/games/acro/all/");
}

=head2 get_acro_starting_letters

=cut

sub get_acro_starting_letters {
    my ( $self, $c, $number_of_letters) = @_;

    if(!$number_of_letters){
       $number_of_letters = 8;
    }
    my @letters_db = $c->model('DB')->resultset('Letters')->all;

    my @letters;
    foreach my $letter(@letters_db) {
       for (my $i = 0; $i < $letter->frequency; $i++) {
          push(@letters, $letter->letter);
       }
    }

    my $string_of_letters = "";
    for (my $i = 0; $i < $number_of_letters; $i++) {
       my $random = rand(scalar(@letters));
       $string_of_letters .= $letters[$random] . " ";
    }
    chomp($string_of_letters);
    $string_of_letters = uc($string_of_letters);

    return $string_of_letters;
}


=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;



