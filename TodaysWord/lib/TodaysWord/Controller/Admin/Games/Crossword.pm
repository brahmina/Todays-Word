package TodaysWord::Controller::Admin::Games::Crossword;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use TodaysWord::Form::Crossword;
use TodaysWord::Model::Crossword;
use TodaysWord::Model::DailyGame;

=head1 NAME

TodaysWord::Controller::Admin::Games::Crossword - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub all :Local {
    my ( $self, $c) = @_;

    my @crosswords = $c->model('DB')->resultset('Crossword')->search({
         scheduled_date => { '=', undef }
    });

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $self->stash_calendar($c, $mon+1, $year+1900);

    $c->stash(template => 'admin/games/crossword/crosswords.tt', crosswords => \@crosswords);
}

=head2 index

=cut

sub index :Path :Args(2) {
    my ( $self, $c, $month, $year ) = @_;


    $c->log->debug("month: $month, year: $year");

    my @crosswords = $c->model('DB')->resultset('Crossword')->search({
         scheduled_date => { '=', undef }
    });

    $self->stash_calendar($c, $month, $year);

    $c->stash(template => 'admin/games/crossword/crosswords.tt', crosswords => \@crosswords);
}

=head2 stash_calendar

=cut

sub stash_calendar {
    my ( $self, $c, $month, $year ) = @_;

    use TodaysWord::Utilities::DailyCalendar;
    my $DailyCalendar = new TodaysWord::Utilities::DailyCalendar();
    my $calendarHTML = $DailyCalendar->getCalendarHTML($c, $month, $year, 'crossword');

    $c->stash(calendar => $calendarHTML);
}

=head2 show

=cut

sub show :Local {
    my ($self, $c, $id) = @_;

    my ($crossword, $cells, $down_clues, $across_clues) = TodaysWord::Model::Crossword->get_crossword_data($c, $id);

    my $date = "Not scheduled";
    my $daily_game = $c->model('DB')->resultset('DailyGame')->search({
            game_table => { '=', 'crossword' },
            game_id => {'=', $id}
       })->single();
    if($daily_game){
       $date = $daily_game->play_date;
    }

    # Inclue the words and definitions for helping with clues
    if(! $crossword->played_date){
       foreach my $down_clue(@{$down_clues}) {
          $self->process_clue($c, $down_clue);
       }
       foreach my $across_clue(@{$across_clues}) {
          $self->process_clue($c, $across_clue);
       }

       $c->stash( template => 'admin/games/crossword/crossword.tt', id => $id, crossword => $crossword, cells => $cells,
               down_clues => $down_clues, across_clues => $across_clues, date => $date);
    }else{
       $c->stash( template => 'admin/games/crossword/crossword.tt', id => $id, crossword => $crossword, cells => $cells,
               down_clues => $down_clues, across_clues => $across_clues, date => $date);
    }
}

=head2 process_clue

=cut

sub process_clue {
    my ($self, $c, $clue) = @_;

   # Get this crossword's word
    my $crossword_word = $c->model('DB')->resultset('CrosswordWord')->search({
         rel_id => { '=', $clue->word_id },
         crossword_id => { '=', $clue->crossword_id }
    })->single();

    $clue->{word} = $crossword_word->word;

    if($crossword_word->dict_word_id){
       # Get the corresponding dict_word entry
       my $dict_word = $c->model('DictDB')->resultset('DictWord')->search({
            id => { '=', $crossword_word->dict_word_id }
       })->single();

       $clue->{definition} = "<ul class='crossword_definitions'>";
       if($dict_word->definition){
          my @definitions = split(" ~~~ ", $dict_word->definition);
          foreach my $def(@definitions) {
             $clue->{definition} .= "<li>$def</li>";
          }
          $clue->{definition} .= "</ul>";
       }else{
          $clue->{definition} = "none";
       }

       if($clue->{synonym}){
          $clue->{synonym} .= $dict_word->synonym;
       }else{
          $clue->{synonym} = $dict_word->synonym;
       }

       # Get all of the possible clues from dict_clue via dict_word_clues
       my @dict_word_clues = $c->model('DictDB')->resultset('DictWordClue')->search({
            word_id => { '=', $crossword_word->dict_word_id }}
       );

       my @clues; my $counter = 0;
       foreach my $dict_word_clue(@dict_word_clues) {
          $clues[$counter] = $c->model('DictDB')->resultset('DictClue')->search({
               id => { '=', $dict_word_clue->clue_id }
          })->single();
          $counter++;
       }
       $clue->{related_clues} = \@clues;
    }else{
       # TODO - Put in interface to add definitions, synonyms and related clues
       $clue->{definition} = "none";
       $clue->{synonym} = "none";
       $clue->{related_clues} = 0;
    }

}

=head2 change_clue

=cut

sub change_clue :Local {
    my ($self, $c, $clue_id) = @_;

    # Temp for ajax loader testing
    my $waittime = time() + 1;
    while (time() < $waittime) {}

    my $clue_param = $c->req->param('clue');
    my $clue = $c->model('DB::CrosswordClue')->find({id => $clue_id});
    if($clue->clue ne $clue_param){

       # Change the value of crossword_clue.clue
       $clue->update({clue => $c->req->param('clue')});

       # Get the corresponding crossword_word via crossword_clue.word_id
       my $word = $c->model('DB::CrosswordWord')->find({rel_id => $clue->word_id,
                                                        crossword_id => $clue->crossword_id});


       # Take care of the dictionary. Check if there is a matching dict_clue for the value passed
       my $dict_clue = $c->model('DictDB::DictClue')->find_or_create({clue => "$clue_param", status => 1});
       my $dict_word_clue = $c->model('DictDB::DictWordClue')->find_or_create({word_id => $word->dict_word_id, clue_id => $dict_clue->id, status => 1});

       $c->log->debug("clue: $clue_param, dict_clue: " . $dict_clue->id .", dict_word_clue: " .$dict_word_clue->id);
    }

    if($c->req->param('ajax')){
       $c->stash( template => 'admin/games/crossword/change_clue.tt', clue => $clue, isAjax => 1);
    }else{
       $self->show($c, $clue->crossword_id);
    }
}

=head2 use_clue

=cut

sub use_clue :Local {
    my ($self, $c, $clue_id, $dict_clue_id) = @_;

    # Temp for ajax loader testing
    my $waittime = time() + 1;
    while (time() < $waittime) {}

    my $clue = $c->model('DB::CrosswordClue')->find({id => $clue_id});
    my $dict_clue = $c->model('DictDB::DictClue')->find({id => $dict_clue_id});

    $clue->update({clue => $dict_clue->clue});

    if($c->req->param('ajax')){
       $c->stash( template => 'admin/games/crossword/use_clue.tt', clue => $clue, dict_clue => $dict_clue);
    }else{
       $self->show($c, $clue->crossword_id);
    }
}

=head2 set_play_date

=cut

sub set_play_date :Local {
    my ($self, $c, $crossword_id) = @_;

    # Temp for ajax loader testing
    my $waittime = time() + 0;
    while (time() < $waittime) {}

    my $crossword = $c->model('DB::Crossword')->find({id => $crossword_id});
    my $date = TodaysWord::Model::DailyGame->set_play_date($c, $c->req->param('the_play_date'), 'crossword', $crossword);

    if($c->req->param('ajax')){
       $c->stash( template => 'admin/games/crossword/set_play_date.tt', date => $date, crossword => $crossword, isAjax => 1);
    }else{
       $self->show($c, $crossword_id);
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
    my ( $self, $c, $crossword_id ) = @_;

    if($crossword_id){
       $c->model('DB::Crossword')->find({id => $crossword_id})->delete;
       $c->model('DB::CrosswordCell')->search({ crossword_id => $crossword_id })->delete;
       $c->model('DB::CrosswordClue')->search({ crossword_id => $crossword_id })->delete;
       $c->model('DB::CrosswordWord')->search({ crossword_id => $crossword_id })->delete;
    }

    $c->response->redirect("/admin/games/crossword/all/");
}


=head2 form

Process the FormHandler crossword form

=cut

sub form {
   my ( $self, $c ) = @_;

   my $form = TodaysWord::Form::Crossword->new;

   my $crossword;
   my $error_message = "";
   if($c->request->params->{file_location}){

      my $valid = 1;
      # Validate the input
      if($valid){
         my $fileUpload = $c->req->upload('file_location');
         
         use Data::Dumper;
         my $d = Dumper($fileUpload);
         print STDERR "!!! The file upload: $d\n";
         
         my $time = time();

         my $file = "admin/files/crosswords/$time.xml";
         my $file_location = $c->config->{full_path}.'/'.$file;
         my $success = $fileUpload->copy_to($file_location);

         # This formats the xml file to use multiple lines
         # Prevents opening files and beautifing then before sending to TW
         my $command = "tidy -xml -wrap 300 $file_location";
         my $output = `$command`;
         open(XML, "+>$file_location") || return;
         print XML $output;
         close XML;

         $c->log->debug("ran command $command -> $output");

         if($success){
            $crossword = $c->model('DB::Crossword')->find_or_create({
                                       description => $c->req->param('description'),
                                       file_location => $file,
                                       width => 15,
                                       height => 15,
                                       create_date => $time
                       });


            # Parse the xml file and load the database with the cells

            my $id = $crossword->id;
            $self->process_xml($c, $crossword);
            $self->get_dict_word_ids($c, $crossword);

            # Redirect the user back to the list page
            $c->response->redirect("/admin/games/crossword/show/".$crossword->id);
         }else{
            $error_message = "File not uploaded";
            $c->stash( template => 'admin/games/crossword/add_crossword.tt', form => $form, error_message => $error_message, crossword => $crossword );
         }

      }else{
         $error_message = "Missing fields!";
         $c->stash( template => 'admin/games/crossword/add_crossword.tt', form => $form, error_message => $error_message, crossword => $crossword );
      }
   }else{
      # Set the template
      $c->stash( template => 'admin/games/crossword/add_crossword.tt', form => $form, error_message => $error_message, crossword => $crossword );
   }
}

=head2 process_xml

Process the FormHandler crossword form

=cut

sub process_xml {
   my ( $self, $c, $crossword ) = @_;

   $c->log->debug("in process_xml");

   my $xml_file = $c->config->{full_path}.'/'.$crossword->file_location;
   open(XML, $xml_file) || return;
   my @lines = <XML>;
   close XML;

   my $across_or_down = 'a';
   foreach my $line(@lines) {
      $c->log->debug("**** line: $line");
      if ($line =~ m/<cell x="(\d+)" y="(\d+)" (.*)><\/cell>/i) {

         my $x = $1;
         my $y = $2;

         my $rest = $3; my $solution; my $number;
         if($rest =~ m/solution="(\w)"/){
            $solution = $1;
         }
         if($rest  =~ m/number="(\d+)"/){
            $number = $1;
         }

         my $cell = $c->model('DB::CrosswordCell')->create({
                                                      crossword_id => $crossword->id,
                                                      x => $x,
                                                      y => $y,
                                                      solution => $solution,
                                                      number => $number
                                      });

      }elsif ($line =~ m/<word id="(\d+)" x="([\d\-]+)" y="([\d\-]+)".*><\/word>/i) {
            my $word_id = $1;
            my $x = $2;
            my $y = $3;

            $c->log->debug("inserting word: $word_id");
            my $word = $c->model('DB::CrosswordWord')->create({
                                                         rel_id => $word_id,
                                                         crossword_id => $crossword->id,
                                                         x => $x,
                                                         y => $y
                                         });

      }elsif($line =~ m/<clue word="(\d+)" number="(\d+)" format="\d+">(.+)<\/clue>/i) {
         my $word = $1;
         my $number = $2;
         my $theClue = $3;

         #$c->log->debug("matched clue");

         my $rest = $3; my $solution;
         if($rest =~ m/solution="(\w)"/){
            $solution = $1;
         }

         $c->log->debug("inserting clue: $theClue");
         my $clue = $c->model('DB::CrosswordClue')->create({
                                       crossword_id => $crossword->id,
                                       number => $number,
                                       across_or_down => $across_or_down,
                                       word_id => $word,
                                       clue => $theClue,
                       });

      }elsif($line =~m/<b>Down<\/b>/){
         $across_or_down = 'd';
      }
   }
}

sub get_dict_word_ids {
   my ( $self, $c, $crossword ) = @_;

   # Associate with crossword_word to dict word

   # Get the crossword cells into an easy to manage hash
   my @cellsdb = $c->model('DB')->resultset('CrosswordCell')->search({
          crossword_id => { '=', $crossword->id }},
         {order_by => 'y, x' }
     );
   my %cells;
   foreach my $cell(@cellsdb) {
      $cells{$cell->x}{$cell->y} = $cell->solution;
   }


   # Get the words
   my @wordsdb = $c->model('DB')->resultset('CrosswordWord')->search({
          crossword_id => { '=', $crossword->id }}
     );

   foreach my $word(@wordsdb) {
      my $wordvalue = "";
      if($word->x =~ m/(\d+)-(\d+)/){

         my $start = $1;
         my $end = $2;
         my $x = $start;
         while ($x <= $end) {
            $wordvalue .= $cells{$x}{$word->y};
            $x++;
         }
      }elsif($word->y =~ m/(\d+)-(\d+)/){

         my $start = $1;
         my $end = $2;
         my $y = $start;
         while ($y <= $end) {
            $wordvalue .= $cells{$word->x}{$y};
            $y++;
         }
      }

      if($wordvalue ne ""){
         # update crossword_word set word = $wordvalue
         $word->update({word => $wordvalue});

         # get the dict_word_id and update the crossword_word
         my @dict_wordsdb = $c->model('DictDB')->resultset('DictWord')->search({
                                 word => { 'LIKE', "$wordvalue" }}
         );

         if(scalar(@dict_wordsdb) > 0){
            my $dict_word = $dict_wordsdb[0];
            # update crossword_word set dict_word_id = $dict_word->id
            $word->update({dict_word_id => $dict_word->id});
         }else{
            # TODO - Give user the interface to handle when the crossword word doesn't match a dict_word
            print STDERR "word not found\n";
         }

      }else{
         print STDERR "failed to build word from cells\n";
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


