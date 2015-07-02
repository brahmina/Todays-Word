package TodaysWord::Utilities::Drawing;
use Moose;
use namespace::autoclean;

=head1 NAME

TodaysWord::Utilities::Drawing 

=head1 DESCRIPTION

Utility for all image manipulation, using ImageMagick

=head1 METHODS

=cut

use Image::Magick;
use Image::Pngslimmer;

=item make_playnow_sprites

=cut

sub make_playnow_sprites {
   my ( $self, $c ) = @_;

   # Not a very efficient way of doing this, but its a by demand, admin only use case, so all good

   my $extension = 'jpeg';
   my $css = ""; my $this_css = "";
   my $image_count = 0; my $this_image_count = 0;

   my @sprites = ('sprite_large', 'sprite_medium', 'sprite_small');

   ($this_css, $this_image_count) = $self->make_playnow_sprite($c, 200, 160, undef, $sprites[0].'.'.$extension); # Large
   $css .= $this_css;
   ($this_css, $this_image_count) = $self->make_playnow_sprite($c, 150, 120, '75%', $sprites[1].'.'.$extension); # Medium
   $css .= $this_css;
   ($this_css, $this_image_count) = $self->make_playnow_sprite($c, 100,  80, '30%', $sprites[2].'.'.$extension); # Small
   $css .= $this_css;
   $image_count = $this_image_count;

   # Little hack to get the right of the sidebar on /playnow
   # 4 is the number of images in a row in the playnow listsing page
   my $listing_images_y_dim = sprintf("%d", $image_count / 4);
   if($image_count % 4){
      $listing_images_y_dim++;
   }
   # 120 is the height of the medium sized images used on the playnow listings page
   # 51 is the margin-top + border + shawdow put on those images
   #$listing_images_y_dim = $listing_images_y_dim * (120+20) + 0;
   #$css .= "#playnow_listing_sidebar {height: " . $listing_images_y_dim . "px}\n";

   # But the css must be written once to reduce dealing with when to clobber dilemas
   open CSS_FILE, "+>$TodaysWord::Setup::PLAYNOW_CSS_FILE" || die "ERROR: Cannot open css file for writing: $!\n";
   print CSS_FILE $css;
   close CSS_FILE;
}

sub make_playnow_sprite {
   my ( $self, $c, $width, $height, $resize_percent, $sprite_name ) = @_;

   my @playnow = $c->model('DB')->resultset('Playnow')->search(
                    {status => { '>', 0 }} );

   my $y_dim = scalar(@playnow) / $TodaysWord::Setup::PLAYNOW_SPRITE_X_DIM;
   if(scalar(@playnow) % $TodaysWord::Setup::PLAYNOW_SPRITE_X_DIM){
      $y_dim = $y_dim + 1;
   }

   my $sprite_width = ($width+10) * $TodaysWord::Setup::PLAYNOW_SPRITE_X_DIM;
   my $sprite_height = ($height+10) * $y_dim;

   my $err; my $css = "";
   my $image; my $x = 0; my $y = 0; 
   
   my $sprite = new Image::Magick(size => $sprite_width."x".$sprite_height);
   $err = $sprite->Read("xc:white");
   if ($err){
       $c->log->debug("ERROR: Image reading error: $err");
   }

   my $image_count = 0;
   foreach my $game (sort{$a->rating <=> $b->rating || $a->rating_count <=> $b->rating_count} @playnow) {

      my $image_file = $game->game.".png";
      if(! -e $TodaysWord::Setup::PLAYNOW_IMAGE_DIR.$image_file){
         next;
      }
      $image_count++;
      $c->log->debug("Reading ".$TodaysWord::Setup::PLAYNOW_IMAGE_DIR.$image_file);
      $c->log->debug("image_count ".$image_count);

      $image = new Image::Magick();
      $err = $image->Read($TodaysWord::Setup::PLAYNOW_IMAGE_DIR.$image_file);
      if ($err){
         $c->log->debug("ERROR: Image reading error: $err");
      }

      if($resize_percent){
         $err = $image->Resize($resize_percent);
         if ($err){
            $c->log->debug("ERROR: Image resize error: $err");
         }
      }
      
      $err = $sprite->Composite(image=>$image, compose=>'over', gravity=>"NorthWest", x => $x, y => $y);
      if ($err){
         $c->log->debug("ERROR: Image drawing error: $err");
      }

      my $modifier = $sprite_name;
      if($modifier =~ m/^sprite_(\w+)\./){
         $modifier = $1;
      }
      if($image_file =~ m/^(\w+)\./){
         $image_file = $1;
      }
      $css .= "#".$image_file."_".$modifier."{ background: url(/static/images/playnow/".$sprite_name.") no-repeat scroll -".$x."px -".$y."px transparent; }\n";
      
 
      $x = $x + $width + 10;
      if($x + $width + 10 > ($width + 10) * $TodaysWord::Setup::PLAYNOW_SPRITE_X_DIM){
         $x = 0;
         $y = $y + $height + 10;
      }
   }

   $c->log->debug("About to write image: $TodaysWord::Setup::PLAYNOW_IMAGE_DIR$sprite_name");
   if($sprite_name =~ m/\.png$/){
      #$sprite->Set( quality => 50 );
   }else{
      $sprite->Set( quality => 70 );
   }
   
   $err = $sprite->Write($TodaysWord::Setup::PLAYNOW_IMAGE_DIR.$sprite_name);

   if ($err){
      $c->log->debug("ERROR: Image writing error: $err");
   }
   
   return ($css, $image_count);
}


__PACKAGE__->meta->make_immutable;

1;

