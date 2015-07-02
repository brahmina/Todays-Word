package TodaysWord::Model::Category;

use strict;

=item init_associate_categories

%params = {selected_categories => optional array of selected categories }

=cut

##################################################
sub init_associate_categories {
##################################################
   my ($self, $c, %params) = @_;

   my $item_categories = $self->get_categories_for_item($c, table => $params{'table'}, table_id => $params{'table_id'});
   my $categories = $self->get_all_categories($c, selected_categories => $item_categories);
   $c->stash( categories => $categories );
}

=item get_all_categories

%params = {selected_categories => optional array of selected categories }

=cut

##################################################
sub get_all_categories {
##################################################
   my ($self, $c, %params) = @_;

   my @categories = $c->model('DB')->resultset('Category')->search(
                            { status => { '=', 1 } }, 
                            { order_by => {-asc => 'name'} }
                        );

   if($params{'selected_categories'}){
      my $selected_categories = $params{'selected_categories'};

      my %selected_categories;
      foreach my $item_cat (@{$selected_categories}) {
         $selected_categories{$item_cat->name} = 1;
      }
      foreach my $cat (@categories) {
         if($selected_categories{$cat->name}){
            $cat->{selected} = 1;
         }
      }
   }

   return \@categories;
}

=item get_all_releasable_categories

%params = {selected_categories => optional array of selected categories }

=cut

##################################################
sub get_all_releasable_categories {
##################################################
   my ($self, $c, %params) = @_;

   my @categories = $c->model('DB')->resultset('Category')->search(
                            { status => { '=', 1 },
                              releasable => { '=', 1 } }, 
                            { order_by => {-asc => 'name'} }
                        );

   $self->get_categories_featured_playnow_games($c, categories => \@categories);

   return \@categories;
}

=item get_categories_featured_playnow_games

%params{categories => \@categories)

=cut

##################################################
sub get_categories_featured_playnow_games {
##################################################
   my ($self, $c, %params) = @_;

   my $categories = $params{'categories'};

   # Put in the featured games
   my $count;
   foreach my $category (@{$categories}) {
      $category->{featured_games} = []; $count = 0;
      my $playnow_games = $self->get_releasable_items_for_category($c, table => 'playnow', category_id => $category->id);
      foreach my $game (sort{$a->rating <=> $b->rating || $a->rating_count <=> $b->rating_count } @{$playnow_games}) {
         if($count < 4){
            push(@{$category->{featured_games}}, $game);
            $count++;
         }
      }
   }

}

=item get_categories_for_item

%params{table => $table_name, 
        table_id => $table_id}

=cut

##################################################
sub get_categories_for_item {
##################################################
   my ($self, $c, %params) = @_;

   my @category_associations = $c->model('DB')->resultset('CategoryAssociation')->search(
         {
         which_table => { '=', $params{"table"} },
         table_id => { '=', $params{"table_id"} }
         }
   );

   if(! scalar(@category_associations)){
      return undef;
   }

   my @category_ids; my %category_associations;
   foreach my $cat_ass(@category_associations) {
      push(@category_ids, $cat_ass->category_id);
      $category_associations{$cat_ass->category_id} = $cat_ass->id;
   }

   my @categories = $c->model('DB')->resultset('Category')->search(
         {
         id => { 'IN', \@category_ids }
         }
   );

   foreach my $cat(@categories) {
      $cat->{category_association_id} = $category_associations{$cat->id};
   }

   return \@categories;
}

=item get_releasable_items_for_category

%params{
        category_id => $category_id},
        table => $table_name - an optional filter
        };

returns %CatatoryAssociations{table}{ids} = @ids
        %CatatoryAssociations{table}{items} = @items

=cut

##################################################
sub get_releasable_items_for_category {
##################################################
   my ($self, $c, %params) = @_;

   # I'm sure there's a smarter way to dso this with passing an optional parameter to dbix class
   #  not sure how though. Could be a TODO for efficiency
   my @releasable_items;
   my $items = $self->get_items_for_category($c, %params);
   foreach my $item(@{$items}) {
      if($item->releasable){
         push(@releasable_items, $item);
      }
   }
   return \@releasable_items;
}

=item get_items_for_category

%params{
        category_id => $category_id},
        table => $table_name - an optional filter
        };

returns %CatatoryAssociations{table}{ids} = @ids
        %CatatoryAssociations{table}{items} = @items

=cut

##################################################
sub get_items_for_category {
##################################################
   my ($self, $c, %params) = @_;

   my @category_associations;
   if($params{"table"}){
      @category_associations = $c->model('DB')->resultset('CategoryAssociation')->search(
            {
            which_table => { '=', $params{"table"} },
            category_id => { '=', $params{"category_id"} }
            }
      );
   }else{
      @category_associations = $c->model('DB')->resultset('CategoryAssociation')->search(
            {
            category_id => { '=', $params{"category_id"} }
            }
      );
   }

   if(! scalar(@category_associations)){
      return undef;
   }
   
   my %category_associations;
   foreach my $cat_ass(@category_associations) {

      if( !$category_associations{$cat_ass->which_table}{'ids'} ){
         $category_associations{$cat_ass->which_table}{'ids'} = $cat_ass->table_id;
      }else{
         $category_associations{$cat_ass->which_table}{'ids'} .= ",".$cat_ass->table_id;
      }
      
   }

   my %return_category_items;
   foreach my $table(keys %category_associations) {
      my $rs_name = $table;
      $rs_name =~ s/_/ /g;
      $rs_name =~ s/(\w+)/\u\L$1/g;
      $rs_name =~ s/ //g;

      my @ids = split(",", $category_associations{$table}{'ids'});
   
      my @items = $c->model('DB')->resultset($rs_name)->search(
            {
            id => { 'IN', \@ids }
            }
      );

      $return_category_items{$table} = \@items;
   }
   
   if($params{"table"}){
        return $return_category_items{$params{"table"}};
   }else{
        return \%return_category_items; 
   }
}


=head1 NAME

TodaysWord::Model::Category 

=head1 SYNOPSIS

See L<TodaysWord>

=head1 DESCRIPTION

TodaysWord::Model::Category

=head1 AUTHOR

marilyn

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
