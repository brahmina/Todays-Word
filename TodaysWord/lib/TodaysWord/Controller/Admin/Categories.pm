package TodaysWord::Controller::Admin::Categories;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use TodaysWord::Form::Category;
use TodaysWord::Model::Category;
use TodaysWord::Utilities::Strings;

=head1 NAME

TodaysWord::Controller::Admin::Category - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index :Path {
    my ( $self, $c) = @_;

    my $categories = TodaysWord::Model::Category->get_all_categories($c);

    foreach my $category(@{$categories}) {
       my $category_associations = TodaysWord::Model::Category->get_items_for_category($c, category_id => $category->id);
       
       foreach my $table(keys %{$category_associations}) {
          $category->{'associations'}->{$table} = scalar(@{$category_associations->{$table}})
       }
    }

    $c->stash(template => 'admin/categories/index.tt', categories => $categories);
}


=head2 add

=cut

sub add :Local {
    my ( $self, $c ) = @_;

    my ($category, $form) = $self->form($c, undef);

    if($category){
       $c->log->debug("redirecting to edit");
       # Redirect the user back to the list page
       $c->response->redirect("/admin/categories/edit/".$category->id);
    }else{
       $c->log->debug("stashing add");
       $c->stash( template => "admin/categories/add.tt", form => $form );
    }
}

=head2 edit

=cut

sub edit :Local :Args(1) {
    my ( $self, $c, $category_id ) = @_;

    my $category = $c->model('DB')->resultset('Category')->find({
         id => { '=', $category_id } 
    });

    my $categorized_items = TodaysWord::Model::Category->get_items_for_category($c, category_id => $category_id);

    # This category returned is sometimes the category object, for add, and 
    #  maybe a success boolean, 0, if the edit fails
    # It's a tad messy
    my ($success, $form) = $self->form($c, $category);
    
    my $custom_submit = $form->custom_submit();
    $custom_submit =~ s/Add/Edit/g;
    $custom_submit =~ s/add/edit/g;
    $form->custom_submit($custom_submit);
    $form->field('which')->value('edit'); 

    # Init categories
    TodaysWord::Model::Category->init_associate_categories($c, table => 'category', table_id => $category_id);

    # Init keywords
    TodaysWord::Model::Keyword->init_associate_keywords($c, table => 'category', table_id => $category_id, item => $category);
    
    $c->stash( template => "admin/categories/edit.tt", form => $form, category => $category, categorized_items => $categorized_items );
}


=head2 form

Process the FormHandler crossword form

=cut

sub form {
   my ( $self, $c, $category ) = @_;

   my $form;
   if($category){
      $form = TodaysWord::Form::Category->new(init_object => $category);
   }else{
      $form = TodaysWord::Form::Category->new();
   }

   my $error_message = "";
   if($c->request->params->{'which'} && $c->request->params->{'which'} eq "add"){

      my $valid = 1;
      # Validate the input
      if($valid){

         $category = $c->model('DB::Category')->find_or_create({
                                       name => $c->req->param('name'),
                                       link_text => $c->req->param('link_text'),
                                       meta_description => $c->req->param('meta_description'),
                                       article => $c->req->param('article'),
                                       seo_name => TodaysWord::Utilities::Strings::getSEO($c->req->param('name'))
                    });
      }else{
         $error_message = "Missing fields!";
         $category = 0;
         $c->stash( form => $form, error_message => $error_message );
      }
   }elsif($c->request->params->{'which'} && $c->request->params->{'which'} eq "edit"){
      my $valid = 1;
      # Validate the input
      if($valid){
         my @fields = ("name", "link_text", "article", "meta_description");
         foreach my $field (@fields) {

            if($c->request->params->{$field} ne $category->$field){
               $category->update({$field => $c->request->params->{$field}});

               if($field eq "name"){
                  $category->update({'seo_name' => TodaysWord::Utilities::Strings::getSEO($c->req->param('name'))});
               }
            }
         }
         $form = TodaysWord::Form::Category->new(init_object => $category);
      }else{
         $error_message = "Missing fields!";
         $category = 0;
         $c->stash( form => $form, error_message => $error_message );
      }
   }else{
      # Set the template
      $category = 0;
      $c->stash( form => $form );
   }

   return ($category, $form);
}

=head2 delete

=cut

sub delete :Local :Args(1) {
    my ( $self, $c, $category_id) = @_;

    if($category_id){
       my $category = $c->model('DB')->resultset('Category')->find({
            id => { '=', $category_id } 
       });
    
       $category->update({'status' => 0});
    }

    $c->response->redirect("/admin/categories");
}

=head2 associate

Associates a set of c

=cut

sub associate :Local {
    my ( $self, $c ) = @_;

    if($c->req->param('c') && $c->req->param('t') && $c->req->param('i')){
        #   category_id             table                item_id          
        my $categories = $c->req->param('c');

        # Clear out the current association
        my $current_categories = $c->model('DB')->resultset('CategoryAssociation')->search({
                     which_table => $c->req->param('t'),
                     table_id => $c->req->param('i')
        });
        $current_categories->delete;

        my @categories = split(",", $categories);
        foreach my $category (@categories) {
           my $association = $c->model('DB::CategoryAssociation')->find_or_create({
                                          category_id => $category,
                                          which_table => $c->req->param('t'),
                                          table_id => $c->req->param('i')
                          });
           if(!$association->status){
              $association->update({'status' => 1});
           }
         }

         TodaysWord::Model::Category->init_associate_categories($c, table => $c->req->param('t'), table_id => $c->req->param('i'));
         $c->stash( error_message => "Categories associatied" );
    }else{
       # This messed right up
       $c->stash( error_message => "No categories selected" );
    }

    $c->stash( template => "admin/categories/associate.tt" );
}

=head2 toggle_releasable

=cut

sub toggle_releasable :Local :Args(1) {
    my ( $self, $c, $category_id ) = @_;

    $c->log->debug("in toggle_releasable");

    my $playnow = $c->model('DB')->resultset('Category')->find({
         id => { '=', $category_id } 
    });

    if($playnow->releasable){
       $playnow->update({'releasable', 0});
    }else{
       $playnow->update({'releasable', 1});
    }

    $c->stash( template => "blank.tt" );
}


=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

