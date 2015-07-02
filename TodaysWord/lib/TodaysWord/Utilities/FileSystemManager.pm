package TodaysWord::Utilities::FileSystemManager;
use Moose;
use namespace::autoclean;

use File::Path qw(remove_tree);

use TodaysWord::Setup;
use TodaysWord::Fault;
use TodaysWord::Utilities::Date;

=head1 NAME

TodaysWord::Utilities::FileSystemManager 

=head1 DESCRIPTION

FileSystemManager method wrapper

=head1 METHODS

=head2 clean_playnow_directory

Evaluates the database and cleans up the orphaned game directories and images

=cut

sub clean_playnow_directory {
   my ($self, $c) = @_;

   $c->log->debug("in clean_playnow_directory");

   #my %db_dir_mapping = ( database_table_dot_name => path_to_thing_to_delete,
   #                        );

   my $playnow_games = TodaysWord::Model::Playnow->get_all_games($c);
   my %playnow_games = map {$_->id => $_} @{$playnow_games};


   my %playnow_zip_and_dir_name;
   my %playnow_images; my %playnow_game_dir;
   foreach my $playnow (@{$playnow_games}) {
      my $code = $playnow->code;
      if($code =~ m|src="\/static\/media\/([-\w]+)\/|){
         $playnow_game_dir{$1} = 1;
      }
      $playnow_images{$playnow->game.".png"} = 1;
   }

   my $playnow_game_directory = "$TodaysWord::Setup::PATH/static/media";
   opendir PLAYNOW_GAME_DIR, "$playnow_game_directory" || 
         TodaysWord::Fault->new(context => $c, 
                              http_status => 500,
                              user_message => "Could not open the playnow games directory",
                              tech_message => "Could not open the playnow games directory ($playnow_game_directory) -> $!")->throw();
   my @game_directories = readdir PLAYNOW_GAME_DIR;
   close PLAYNOW_GAME_DIR;

   foreach my $dir(@game_directories) {
      if($dir !~ m/^\./ && $dir ne "__unzipped" && !$playnow_game_dir{$dir}){
         remove_tree("$TodaysWord::Setup::PATH/static/media/$dir");
         $c->log->debug("Deleted: $TodaysWord::Setup::PATH/static/media/$dir");
      }
   }

   my $playnow_images_directory = "$TodaysWord::Setup::PATH/static/images/playnow";
   opendir PLAYNOW_IMAGES_DIR, "$playnow_images_directory" || 
         TodaysWord::Fault->new(context => $c, 
                              http_status => 500,
                              user_message => "Could not open the playnow images directory",
                              tech_message => "Could not open the playnow images directory ($playnow_images_directory) -> $!")->throw();
   my @images_in_dir = readdir PLAYNOW_IMAGES_DIR;
   close PLAYNOW_IMAGES_DIR;
   
   foreach my $image_name(@images_in_dir) {
      if(! $playnow_images{$image_name} && $image_name =~ m/\.png$/){
         $c->log->debug("Deleted: $TodaysWord::Setup::PATH/static/images/playnow/$image_name");
         unlink("$TodaysWord::Setup::PATH/static/images/playnow/$image_name");
      }
   }


}
=head1 AUTHOR

Marilyn

=head1 LICENSE


=cut

__PACKAGE__->meta->make_immutable;

1;


