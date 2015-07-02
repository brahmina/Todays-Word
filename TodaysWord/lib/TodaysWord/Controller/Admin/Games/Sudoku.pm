package TodaysWord::Controller::Admin::Games::Sudoku;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use TodaysWord::Form::Sudoku;
use TodaysWord::Model::DailyGame;

=head1 NAME

TodaysWord::Controller::Admin::Games::Sudoku - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 all

=cut

sub all :Local {
    my ( $self, $c) = @_;

    my @sudokus = $c->model('DB')->resultset('Sudoku')->search({
         scheduled_date => { '=', undef }
    });

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $self->stash_calendar($c, $mon+1, $year+1900);

    $c->stash(template => 'admin/games/sudoku/sudokus.tt', sudokus => \@sudokus);
}

=head2 index

=cut

sub index :Path :Args(2) {
    my ( $self, $c, $month, $year ) = @_;


    $c->log->debug("month: $month, year: $year");

    my @sudokus = $c->model('DB')->resultset('Sudoku')->search({
         scheduled_date => { '=', undef }
    });

    $self->stash_calendar($c, $month, $year);

    $c->stash(template => 'admin/games/sudoku/sudokus.tt', sudokus => \@sudokus);
}

=head2 stash_calendar

=cut

sub stash_calendar {
    my ( $self, $c, $month, $year ) = @_;

    use TodaysWord::Utilities::DailyCalendar;
    my $DailyCalendar = new TodaysWord::Utilities::DailyCalendar();
    my $calendarHTML = $DailyCalendar->getCalendarHTML($c, $month, $year, 'sudoku');

    $c->stash(calendar => $calendarHTML);
}

=head2 show

=cut

sub show :Local {
    my ($self, $c, $id) = @_;

    my $sudoku = $c->model('DB::Sudoku')->find({id => $id});
    my @cells = $c->model('DB::SudokuCell')->search(
         {sudoku_id => $sudoku->id},
         {order_by => 'y, x' });

    my $date = "Not scheduled";
    my $daily_game = $c->model('DB')->resultset('DailyGame')->search({
            game_table => { '=', 'sudoku' },
            game_id => {'=', $id}
       })->single();

    if($daily_game){
       $date = $daily_game->play_date;
    }

    # Inclue the words and definitions for helping with clues
    $c->stash( template => 'admin/games/sudoku/sudoku.tt', id => $id, sudoku => $sudoku, cells => \@cells, date => $date);
}


=head2 set_play_date

=cut

sub set_play_date :Local {
    my ($self, $c, $sudoku_id) = @_;

    # Temp for ajax loader testing
    my $waittime = time() + 0;
    while (time() < $waittime) {}

    my $sudoku = $c->model('DB::Sudoku')->find({id => $sudoku_id});
    my $date = TodaysWord::Model::DailyGame->set_play_date($c, $c->req->param('the_play_date'), 'sudoku', $sudoku);


    if($c->req->param('ajax')){
       $c->stash( template => 'admin/games/sudoku/set_play_date.tt', date => $date, sudoku => $sudoku, isAjax => 1);
    }else{
       $self->show($c, $sudoku_id);
    }
}


=head2 add

=cut

sub add :Local {
    my ( $self, $c ) = @_;

    my $form = $self->form($c);
    return $form;
}

=head2 delete

=cut

sub delete :Local {
    my ( $self, $c, $sudoku_id ) = @_;

    if($sudoku_id){
       $c->model('DB::Sudoku')->find({id => $sudoku_id})->delete;
       $c->model('DB::SudokuCell')->search({ sudoku_id => $sudoku_id })->delete;
    }

    $c->response->redirect("/admin/games/sudoku/all/");
}

=head2 form

Process the FormHandler Sudoku form

=cut

sub form {
   my ( $self, $c ) = @_;

   my $form = TodaysWord::Form::Sudoku->new;

   $c->log->debug("in sudoku form! " .$c->req->param('submit'));

   my $sudoku;
   my $error_message = "";
   if($c->req->param('file_location')){
      $c->log->debug("here!");
      my $valid = 0;
      if($c->req->param('file_location')){
         $valid = 1;
      }
      # Validate the input
      if($valid){
         $c->log->debug("valid!");
         my $fileUpload = $c->req->upload('file_location');
         my $time = time();

         my $file = "admin/files/sudokus/$time.xml";
         my $file_location = $c->config->{full_path}.'/'.$file;
         my $success = $fileUpload->copy_to($file_location);


         # This formats the xml file to use multiple lines
         # Prevents opening files and beautifing then before sending to TW
         my $command = "tidy -xml -wrap 300 $file_location";
         my $output = `$command`;
         open(XML, "+>$file_location") || return;
         print XML $output;
         close XML;

         if($success){

            $c->log->debug("success!");

            $sudoku = $c->model('DB::Sudoku')->find_or_create({
                                       description => $c->req->param('description'),
                                       file_location => $file,
                                       width => 9,
                                       height => 9,
                                       create_date => $time
                       });


            # Parse the xml file and load the database with the cells

            my $id = $sudoku->id;
            $self->process_xml($c, $sudoku);
            $c->response->redirect("/admin/games/sudoku/show/".$sudoku->id);
         }else{
            $error_message = "File not uploaded";
            $c->stash( form => $form, error_message => $error_message, sudoku => $sudoku );
         }
      }else{
         $error_message = "Missing fields!";
         $c->stash( template => 'admin/games/sudoku/add_sudoku.tt', form => $form, error_message => $error_message, sudoku => $sudoku );
      }
   }else{
      # Set the template
      $c->stash( template => 'admin/games/sudoku/add_sudoku.tt', form => $form, error_message => $error_message, sudoku => $sudoku );
   }
}

=head2 form

Process the FormHandler Sudoku form

=cut

sub process_xml {
   my ( $self, $c, $sudoku ) = @_;

   $c->log->debug("in process_html");

   open(XML, $c->config->{full_path}.'/'.$sudoku->file_location) || return;
   my @lines = <XML>;
   close XML;

   foreach my $line(@lines) {
      if ($line =~ m/<cell x="(\d+)" y="(\d+)"([\s\w\-"=]+)><\/cell>/i) {
         my $x = $1;
         my $y = $2;
         my $rest = $3;

         my $solution; my $hint; my $topbar;
         if($rest =~ m/solution="(\w)"/){
            $solution = $1;
         }
         if($rest  =~ m/top-bar="true"/){
            $topbar = 1;
         }
         if($rest  =~ m/hint="true"/){
            $hint = 1;
         }


         my $cell = $c->model('DB::SudokuCell')->find_or_create({
                                                      sudoku_id => $sudoku->id,
                                                      x => $x,
                                                      y => $y,
                                                      solution => $solution,
                                                      hint => $hint,
                                                      topbar => $topbar
                                      });

      }
   }
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;



