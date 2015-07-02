#!/usr/bin/perl
#
# Image composition with alpha transparency demo.
# logo.png (32-bit PNG with alpha channel) is required.
#
# http://www.dylanbeattie.net/magick/composite/
use Image::Magick;
# Create background image - a 300x200 white-to-black gradient
$background=Image::Magick->new;
$logo = Image::Magick->new;
$background->Set(size=>'300x200');
$background->Read("gradient:white-black");
# Read the transparent logo from the PNG file
$logo->Read("png:logo.png");
# Call the Composite method of the background image, with the logo image as an argument.
$background->Composite(image=>$logo,compose=>'over');
$background->Set(quality=>100);
$background->Write("jpg:output.jpg");

# Clean up
undef $background;
undef $logo;
