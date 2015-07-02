package TodaysWord::Controller::Admin::Games::Caption;
use Moose;
use namespace::autoclean;

use Image::Size;
use Image::Magick;

BEGIN {extends 'Catalyst::Controller'; }

use TodaysWord::Model::Caption;
use TodaysWord::Form::Caption;
use TodaysWord::Model::DailyGame;

=head1 NAME

TodaysWord::Controller::Admin::Games::Caption - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub all :Local {
    my ( $self, $c) = @_;

    my @captions = $c->model('DB')->resultset('Caption')->search({
         scheduled_date => { '=', undef }
    });

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $self->stash_calendar($c, $mon+1, $year+1900);

    $c->stash(template => 'admin/games/caption/captions.tt', captions => \@captions);
}


=head2 index

=cut

sub index :Path :Args(2) {
    my ( $self, $c, $month, $year ) = @_;

    $c->log->debug("month: $month, year: $year");

    my @captions = $c->model('DB')->resultset('Caption')->search({
         scheduled_date => { '=', undef }
    });

    $self->stash_calendar($c, $month, $year);

    $c->stash(template => 'admin/games/caption/captions.tt', captions => \@captions);
}

=head2 stash_calendar

=cut

sub stash_calendar {
    my ( $self, $c, $month, $year ) = @_;

    use TodaysWord::Utilities::DailyCalendar;
    my $DailyCalendar = new TodaysWord::Utilities::DailyCalendar();
    my $calendarHTML = $DailyCalendar->getCalendarHTML($c, $month, $year, 'caption');

    $c->stash(calendar => $calendarHTML);
}

=head2 show

=cut

sub show :Local {
    my ($self, $c, $id) = @_;

    $c->log->debug("caption id: $id");

    my ($caption, $bubbles, $bubble_count) = TodaysWord::Model::Caption->get_caption_data($c, $id);

    my $date = "Not scheduled";
    my $daily_game = $c->model('DB')->resultset('DailyGame')->search({
            game_table => { '=', 'caption' },
            game_id => {'=', $id}
       })->single();
    if($daily_game){
       $date = $daily_game->play_date;
    }

    # Inclue the words and definitions for helping with clues
    $c->stash( template => 'admin/games/caption/caption.tt', id => $id, caption => $caption,  bubbles => $bubbles,
                              bubble_count => $bubble_count, date => $date);
}

=head2 add_bubble

=cut

sub add_bubble :Local {
    my ($self, $c, $bubble_count) = @_;

    my %bubble = (width => 150,
                  height => 40,
                  top => 10,
                  fromleft => 10,
                  fontsize => 24,
                  background => "white",
                  border => "1px solid #000000",
                  font => "Comic Sans MS",
                  count => $bubble_count
                  );

    $c->stash( template => 'admin/games/caption/bubble_info.tt', bubble_count => $bubble_count, bubble => \%bubble);

}

=head2 save_bubbles

=cut

sub save_bubbles :Local {
    my ($self, $c) = @_;

    my $caption_id = $c->req->param('caption_id');
    my $caption = $c->model('DB::Caption')->find({id => $caption_id});

    $c->log->debug("in save_bubbles with caption: $caption_id");

    my %bubbles_to_save;
    foreach my $param($c->req->param()) {
       if($param =~ m/bubble_(\w+)_(\d+)/){
          $bubbles_to_save{$2}{$1} = $c->req->param($param);
       }
    }

    foreach my $id(sort keys %bubbles_to_save) {
       $bubbles_to_save{$id}{'class'} = "";
       $bubbles_to_save{$id}{'count'} = $id;
       foreach my $field(sort keys %{$bubbles_to_save{$id}}) {
          if($field eq "fontsize"){
             $bubbles_to_save{$id}{'class'} .= "font-size: $bubbles_to_save{$id}{$field}px;\n";
          }elsif($field eq "font"){
             $bubbles_to_save{$id}{'class'} .= "font-family: $bubbles_to_save{$id}{$field};\n";
          }elsif($field eq "width" || $field eq "height" || $field eq "top" || $field eq "left"){
             $bubbles_to_save{$id}{'class'} .= "$field: $bubbles_to_save{$id}{$field}px;\n";
          }elsif($field eq 'customcss'){
             $bubbles_to_save{$id}{'class'} .= $bubbles_to_save{$id}{$field} .";\n";
          }elsif($field && $field ne 'class' && $field ne 'count'){
             $bubbles_to_save{$id}{'class'} .= "$field: $bubbles_to_save{$id}{$field};\n";
          }
       }
    }

    my @bubbles = $c->model('DB')->resultset('CaptionBubble')->search({
         caption_id => { '=', $caption_id }
    });

    foreach my $id(keys %bubbles_to_save) {
       if($bubbles[$id-1]){
          my $bubble = $bubbles[$id-1];
          if($bubble->class ne $bubbles_to_save{$id}{'class'}){
             $bubble->update({class => $bubbles_to_save{$id}{'class'},
                              width => $bubbles_to_save{$id}{'width'},
                              height => $bubbles_to_save{$id}{'height'},
                              top => $bubbles_to_save{$id}{'top'},
                              fromleft => $bubbles_to_save{$id}{'left'},
                              fontsize => $bubbles_to_save{$id}{'fontsize'},
                              font => $bubbles_to_save{$id}{'font'},
                              background => $bubbles_to_save{$id}{'background'},
                              border => $bubbles_to_save{$id}{'border'},
                              font => $bubbles_to_save{$id}{'font'},
                              customcss => $bubbles_to_save{$id}{'customcss'}
                              });
          }
       }else{
          my $bubble = $c->model('DB::CaptionBubble')->create({
                                                            caption_id => $caption_id,
                                                            class => $bubbles_to_save{$id}{'class'},
                                                            width => $bubbles_to_save{$id}{'width'},
                                                            height => $bubbles_to_save{$id}{'height'},
                                                            top => $bubbles_to_save{$id}{'top'},
                                                            fromleft => $bubbles_to_save{$id}{'left'},
                                                            fontsize => $bubbles_to_save{$id}{'fontsize'},
                                                            font => $bubbles_to_save{$id}{'font'},
                                                            background => $bubbles_to_save{$id}{'background'},
                                                            border => $bubbles_to_save{$id}{'border'}
          });
       }
    }

    $c->response->redirect("/admin/games/caption/show/".$caption->id);
}

=head2 reset_bubbles

=cut

sub reset_bubbles :Local {
    my ($self, $c, $caption_id) = @_;

    $c->log->debug("in reset_bubbles with caption: $caption_id");

    my ($caption, $bubbles, $bubble_count) = TodaysWord::Model::Caption->get_caption_data($c, $caption_id);

    foreach my $bubble(@{$bubbles}) {
       $bubble->delete();
    }

    $c->response->redirect("/admin/games/caption/show/".$caption->id);
}

=head2 set_play_date

=cut

sub set_play_date :Local {
    my ($self, $c, $caption_id) = @_;

    # Temp for ajax loader testing
    my $waittime = time() + 0;
    while (time() < $waittime) {}

    my $caption = $c->model('DB::Caption')->find({id => $caption_id});
    my $date = TodaysWord::Model::DailyGame->set_play_date($c, $c->req->param('the_play_date'), 'caption', $caption);

    if($c->req->param('ajax')){
       $c->stash( template => 'admin/games/caption/set_play_date.tt', date => $date, caption => $caption, isAjax => 1);
    }else{
       $c->response->redirect("/admin/games/caption/show/".$caption->id);
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

Process the FormHandler caption form

=cut

sub form {
   my ( $self, $c ) = @_;

   my $form = TodaysWord::Form::Caption->new;

   $c->log->debug("in caption form! " .$c->req->param('file_location'));

   my $caption;
   my $error_message = "";
   if($c->request->params->{'file_location'}){
      my $valid = 1;
      # Validate the input
      if($valid){
         my $fileUpload = $c->req->upload('file_location');
         my $time = time();

         # TODO -> Add a type dropdown (caption, modern image, old image, drawing)
         $caption = $c->model('DB::Caption')->find_or_create({
                                       title => $c->req->param('title'),
                                       source => $c->req->param('source'),
                                       create_date => $time
                       });

         my $extension = "png";
         if($fileUpload =~ m/\.(\w)$/){
               $extension = $1;
         }
         $extension = lc($extension);

         my $id = $caption->id;
         my $original_file = "admin/files/captions/$id.$extension";
         my $original_file_location = $c->config->{full_path}.'/'.$original_file;
         my $success = $fileUpload->copy_to($original_file_location);

         my $optimized_file = "/static/captions/$id.$extension";
         my $optimized_file_location = $c->config->{full_path}.$optimized_file;

         # TODO -> ImageMagick to resize down to 560px wide max
         #      -> Keep original in admin/files/($id.$extension)
         #      -> Put resize in static/images/captions/($id.$extension)

         my ($width, $height) = imgsize($original_file_location);

         $c->log->debug("image size: width: $width, height: $height");
         if($width > $TodaysWord::Setup::MAX_CAPTION_WIDTH){
            my $ImageMagick = Image::Magick->new;
            my $err = $ImageMagick->Read($original_file_location);
            if ($err){
               $c->log->warn("Image resizing error: $err");
               $success = 0;
            }

            my $geo = $TodaysWord::Setup::MAX_CAPTION_WIDTH . "x" . $TodaysWord::Setup::MAX_CAPTION_WIDTH;
            $err = $ImageMagick->AdaptiveResize(geometry=>$geo, blur => 0.3);
            if ($err){
               $c->log->warn("Image resizing error: $err");
               $success = 0;
            }

            if($extension =~ m/jpeg/i || $extension =~ m/jpg/i){
               $err = $ImageMagick->Set(compression => 'JPEG', quality => $TodaysWord::Setup::CAPTION_IMAGE_QUALITY);
            }else{
               $err = $ImageMagick->Set(quality => $TodaysWord::Setup::CAPTION_IMAGE_QUALITY);
            }
            if ($err){
               $c->log->warn("Image resizing error: $err");
               $success = 0;
            }
            $err = $ImageMagick->Write($optimized_file_location);
            if ($err){
               $c->log->warn("Image resizing error: $err");
               $success = 0;
            }

            ($width, $height) = imgsize($optimized_file_location);
         }else{
            # copy it to the public directory
            my $command = "cp $original_file_location $optimized_file_location";
            my $output = `$command`;
            $c->log->warn("Error with cmd: $command -> $output") if $output;
         }

         $caption->update({original_location => $original_file_location});
         $caption->update({optimized_location => $optimized_file});
         $caption->update({width => $width});
         $caption->update({height => $height});
         if($success){
            my $id = $caption->id;
            $error_message = "Sucessfully added caption id -> $id";
            $c->response->redirect("/admin/games/caption/show/".$caption->id);
         }else{
            $c->response->redirect("/admin/error");
         }
      }else{
         $error_message = "Missing fields!";
         $c->stash( template => 'admin/games/caption/add_caption.tt', form => $form, error_message => $error_message, caption => $caption );
      }
   }else{
      # Set the template
      $c->stash( template => 'admin/games/caption/add_caption.tt', form => $form, error_message => $error_message, caption => $caption );
   }
}

=head2 delete

=cut

sub delete :Local {
    my ( $self, $c, $caption_id ) = @_;

    if($caption_id){
       $c->model('DB::Caption')->find({id => $caption_id})->delete;
       $c->model('DB::CaptionBubble')->search({ crossword_id => $caption_id })->delete;
       $c->model('DB::CaptionEntry')->search({ crossword_id => $caption_id })->delete;
    }

    $c->response->redirect("/admin/games/caption/all/");
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;


