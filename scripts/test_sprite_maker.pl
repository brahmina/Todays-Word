#!/usr/bin/perl

#eval 'exec /usr/bin/perl  -S $0 ${1+"$@"}'
#    if 0; # not running under some shell

use Image::Magick;

my $err;

my $image1 = Image::Magick->new();
$err = $image1->Read('png:/home/www-data/todays-word.com/TodaysWord/root/static/images/playnow/alphabetsoup.png');
print "ERROR 1: $err\n$!\n" if($err);

my $image2 = Image::Magick->new();
$err = $image2->Read('png:/home/www-data/todays-word.com/TodaysWord/root/static/images/playnow/roboflu.png');
print "ERROR 2: $err\n$!\n" if($err);

my $sprite=Image::Magick->new(size=>"600x600",fill=>'white');
$err = $sprite->Read("xc:white");
print "ERROR 3: $err\n$!\n" if($err);
$err = $sprite->Composite(image=>$image1,compose=>'over',gravity=>'NorthWest',x=>100,y=>100);
print "ERROR 4: $err\n$!\n" if($err);

$sprite->Set(quality=>100);
$err = $sprite->Write("jpg:/home/output2.jpg");
print "ERROR 5: $err\n$!\n" if($err);


