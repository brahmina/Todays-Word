package TodaysWord::Controller::Admin::Articles;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use TodaysWord::Form::Article;
use TodaysWord::Model::Category;
use TodaysWord::Utilities::Strings;

=head1 NAME

TodaysWord::Controller::Admin::Articles - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path {
    my ( $self, $c) = @_;

    my $articles = TodaysWord::Model::Article->get_all_articles($c);

    $c->stash(template => 'admin/articles/index.tt', articles => $articles);
}

=head2 add

=cut

sub add :Local {
    my ( $self, $c ) = @_;

    my ($success, $form) = $self->form($c, undef);

    if($success){
       # Redirect the user back to the list page
       $c->response->redirect("/admin/articles/");
    }else{
       $c->stash( template => "admin/articles/add.tt" );
    }
}

=head2 edit

=cut

sub edit :Local :Args(1) {
    my ( $self, $c, $article_id ) = @_;

    my $article = $c->model('DB')->resultset('Article')->find({
         id => { '=', $article_id } 
    });

    my ($success, $form) = $self->form($c, $article);
    $c->stash( form => $form );

    my $custom_submit = $form->custom_submit();
    $custom_submit =~ s/Add/Edit/g;
    $custom_submit =~ s/add/edit/g;
    $form->custom_submit($custom_submit);
    $form->field('which')->value('edit'); 

    # Init categories
    TodaysWord::Model::Category->init_associate_categories($c, table => 'article', table_id => $article_id);

    # Init keywords
    TodaysWord::Model::Keyword->init_associate_keywords($c, table => 'article', table_id => $article_id, item => $article);
    
    $c->stash( template => "admin/articles/edit.tt", article => $article );
}

=head2 form

Process the FormHandler crossword form

=cut

sub form {
   my ( $self, $c, $article ) = @_;

   my $form;
   if($article){
      $form = TodaysWord::Form::Article->new(init_object => $article);
   }else{
      $form = TodaysWord::Form::Article->new();
   }

   my $game;
   my $error_message = "";
   if($c->request->params->{'which'} && $c->request->params->{'which'} eq "add"){

      my $valid = 1;
      if(! $c->request->params->{'title'} || ! $c->request->params->{'written_where'}){
         $valid = 0;
      }
      # Validate the input
      if($valid){
         my @articles = $c->model('DB')->resultset('Article')->search(
             { status => { '=', 1 } }, 
             { order_by => {-asc => 'written_where'} }
         );
         
         $game = $c->model('DB::Article')->find_or_create({
                                    title => $c->req->param('title'),
                                    written_where => $c->req->param('written_where'),
                                    content => $c->req->param('content'),
                    });

         

         return (1, $form);

      }else{
         $c->stash( form => $form, error_message => "Missing fields!" );
         return (0, $form);
      }
   }elsif($c->request->params->{'which'} && $c->request->params->{'which'} eq "edit"){
      my $valid = 1;
      # Validate the input
      if($valid){
         my @fields = ("title", "written_where", "content");
         foreach my $field (@fields) {

            $c->log->debug("field: $field");
            $c->log->debug("param: ".$c->request->params->{$field});
            $c->log->debug("attribute: ".$article->$field);


            if($c->request->params->{$field} ne $article->$field){
               $article->update({$field => $c->request->params->{$field}});
            }

         }
         $form = TodaysWord::Form::Article->new(init_object => $article);
         return (1, $form);
      }else{
         $c->stash( game => $article, error_message => "Missing fields!" );
         return (0, $form);
      }
   }else{
      $c->stash( form => $form );
      return (0, $form);
   }
}

=head2 delete

=cut

sub delete :Local :Args(1) {
    my ( $self, $c, $article_id) = @_;

    if($article_id){
       my $game = $c->model('DB')->resultset('Article')->find({
            id => { '=', $article_id } 
       });
    
       $game->update({'status' => 0});
    }

    $c->response->redirect("/admin/articles/");
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

