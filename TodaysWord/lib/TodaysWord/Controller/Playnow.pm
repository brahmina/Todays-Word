package TodaysWord::Controller::Playnow;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use TodaysWord::Utilities::SocialButtons;
use POSIX qw(ceil floor);

=head1 NAME

TodaysWord::Controller::Games - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Regex('playnow/(\d*?)$') {
    my ( $self, $c ) = @_;

    my ( $page ) = @{ $c->req->captures };

    my $games = TodaysWord::Model::Playnow->get_releasable_games($c, $page);
    my $games_count = TodaysWord::Model::Playnow->get_all_releasable_games_count($c);
    my $pages_count = ceil($games_count / $TodaysWord::Setup::PLAYNOW_GAMES_PER_PAGE);

    my $categories = TodaysWord::Model::Category->get_all_categories($c);
    
    # This is the 'Word Games to Play Online' article for the copy on the playnow page
    my $meta_keywords = TodaysWord::Model::Keyword->get_keywords_for_item($c, table => 'article', table_id => 4);

    if($c->req->param('ajax') == 1){
       $c->stash( template => 'playnow/playnow_listing.tt' );
    }else{
       $c->stash( template => 'playnow/index.tt' );
    }

    $c->stash( games => $games, categories => $categories, meta_keywords => $meta_keywords,
               games_count => $games_count, pages_count => $pages_count, current_page => $page ? $page : 1);
}

=head2 category

=cut

sub category :Local :Args(2) {
    my ( $self, $c, $category_seo, $category_id ) = @_;

    my $category = $c->model('DB')->resultset('Category')->find(
          { id => { '=', $category_id } }
    );
    if(! $category){
        $c->response->status(404);
        $c->stash( template => '404.tt');
        return;
    }
    
    my $games = TodaysWord::Model::Category->get_items_for_category($c, table => 'playnow', category_id => $category_id);
    
    my $meta_keywords = TodaysWord::Model::Keyword->get_keywords_for_item($c, table => 'catagory', table_id => $category_id);
    my $meta_description = "Play free word games - ". $category->name;

    my $categories = TodaysWord::Model::Category->get_categories_for_item($c, table => 'category', table_id => $category_id);
    TodaysWord::Model::Category->get_categories_featured_playnow_games($c, categories => $categories);

    $c->stash( template => 'playnow/category.tt', games => $games, category => $category, categories => $categories,
               meta_keywords => $meta_keywords, meta_description => $meta_description );
}

=head2 categories

=cut

sub categories :Local  {
    my ( $self, $c ) = @_;

    my $categories = TodaysWord::Model::Category->get_all_releasable_categories($c);

    my $meta_keywords;
    my $meta_description = "Play free word games - Category listing";

    $c->stash( template => 'playnow/categories.tt', categories => $categories,
               meta_keywords => $meta_keywords, meta_description => $meta_description );
}

=head2 play

=cut

sub play :Local :Args(2) {
    my ( $self, $c, $seo_name, $playnow_id ) = @_;

    my $game = TodaysWord::Model::Playnow->get_playnow_game($c, $playnow_id);
    if(! $game){
        $c->response->status(404);
        $c->stash( template => '404.tt');
        return;
    }

    my $url = $c->request->uri;
    my $title = "Play ".$game->name." at Today's Word!";
    my $social_buttons = TodaysWord::Utilities::SocialButtons->get_social_buttons($c, url => $url, title => $title);
    my ($current_rating, $current_rating_count) = TodaysWord::Model::Playnow->get_current_playnow_rating($c, $playnow_id);
    my $current_rating_width = TodaysWord::Model::Playnow->get_current_rating_width($c, $current_rating);

    my @related_playnows;
    my $categories = TodaysWord::Model::Category->get_categories_for_item($c, table => 'playnow', table_id => $playnow_id);
    foreach my $category (@{$categories}) {
       my $items = TodaysWord::Model::Category->get_items_for_category($c, table => 'playnow', category_id => $category->id);
       push(@related_playnows, @$items);
    }
    my @related_games;
    if(scalar(@related_playnows) > 4){ # 4 spots on the playnow page for related games 
       @related_games = @related_playnows[0..3];
    }else{
       @related_games = @related_playnows;
    }
      
    my $meta_keywords = TodaysWord::Model::Keyword->get_keywords_for_item($c, table => 'playnow', table_id => $playnow_id);
    my $meta_description = "Play ".$game->name.". One of the many online word games at Today's Word!";
    
    $c->stash( template => 'playnow/play.tt', game => $game, social_buttons => $social_buttons, categories => $categories,
               current_rating => $current_rating, current_rating_width => $current_rating_width, related_games => \@related_games, 
               meta_keywords => $meta_keywords, meta_description => $meta_description);
}

=head2 rate

=cut

sub rate :Local :Args(3) {
    my ( $self, $c, $seo_name, $playnow_id, $rating ) = @_;

    my $waittime = time() + 1;
    while (time() < $waittime) {}

    my $playnow = $c->model('DB::Playnow')->find({id => $playnow_id});

    my $user_id;
    my $game_rating;
    my $today_less_7_days = time() - 60*60*24*7; # One rating a week?
    # Has this person rated this entry yet in the last day
    if($c->user_exists){
       $user_id = $c->user->id;

       $game_rating = $c->model('DB')->resultset('PlaynowRating')->search({
                                              playnow_id => { '=', $playnow_id },
                                              user_id  => { '=', $user_id },
                                            })->single;
    }else{
       $game_rating = $c->model('DB')->resultset('PlaynowRating')->search({
                                              playnow_id => { '=', $playnow_id },
                                              ip  => { '=', $c->request->address }
                                              
        #my $today_less_7_days = time() - 60*60*24*7; # One rating a week? Nah! One rating per person
                                             #create_date => { '>', $today_less_7_days }
        # TODO - Consider changing this to include the user agent in identifying the gues vote                                              
                                            })->single;
    }

    if(defined($game_rating)){
       $game_rating->update({rating => $rating, create_date => time()});
    }else{
       $game_rating = $c->model('DB::PlaynowRating')->create({
                                          playnow_id => $playnow_id,
                                          rating => $rating,
                                          user_id => $user_id,
                                          create_date => time(),
                                          ip => $c->request->address,
                                          status => 1
                                   });
    }

    # Set the convenience columns rating and rating_count in the playnow table
    my ($current_rating, $current_rating_count) = TodaysWord::Model::Playnow->get_current_playnow_rating($c, $playnow_id);
    $playnow->update({rating => $current_rating, rating_count => $current_rating_count});


    if($c->req->param('ajax') == 1){
       # return
       my ($current_rating, $current_rating_count) = TodaysWord::Model::Playnow->get_current_playnow_rating($c, $playnow_id);
       my $current_rating_width = TodaysWord::Model::Playnow->get_current_rating_width($c, $current_rating);
       $c->stash( template => 'playnow/star_rating.tt', game => $playnow, current_rating_count => $current_rating_count,
                  current_rating => $current_rating, current_rating_width => $current_rating_width);
    }else{
       $c->response->redirect("/playnow/play/$seo_name/$playnow_id");
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



