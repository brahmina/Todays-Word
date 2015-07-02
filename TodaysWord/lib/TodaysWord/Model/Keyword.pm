package TodaysWord::Model::Keyword;

use strict;

use JSON;

=item init_keywords

Gets the keywords needed for associating keywords on an item, and puts them in stash

=cut

##################################################
sub init_associate_keywords {
##################################################
    my ($self, $c, %params ) = @_;

    $c->log->debug("in TodaysWord::Model::Keyword->init_keywords");

    my $associated_keywords = $self->get_keywords_for_item($c, %params); 
    my $associated_keywords_js = $self->get_keywords_for_item_js($c, associated_keywords => $associated_keywords, %params); 
    my $keyword_list_js = $self->get_keyword_list_js($c, associated_keywords => $associated_keywords);

    $c->stash( keyword_list_js => $keyword_list_js, # for the auto suggest
               item => $params{'item'}, 
               associated_keywords => $associated_keywords, # for the html table of currently associated tags
               associated_keywords_js => $associated_keywords_js ); # for the pre add tags in the autosuggest box 
}

=item get_keywords

Returns an array of keywords, filtered by what's in 
   $c->request->params->{p} (page)
   $c->request->params->{l}(limit) 
   $c->request->params->{i} (import)

=cut

##################################################
sub get_keywords {
##################################################
   my ($self, $c ) = @_;

   my $page = $c->request->params->{p} ? $c->request->params->{p} : 1;
   my $limit = $c->request->params->{l} ? $c->request->params->{l} : 250;
   my $import = $c->request->params->{i} ? $c->request->params->{i} : 12; # All word games import

   # TODO -> Are these the same?
   my @keywords = $c->model('DB')->resultset('Import')->find({ id => $import })->keywordimports->search_related(
         'keyword',
         {
         status => { '=', 1 }
         },
         {
         page => $page,  # page to return (defaults to 1)
         rows => $limit, # number of results per page
         order_by => 'keyworth DESC' 
         }
   );

   # To prevent oxford comma in sorta table javascript
   $keywords[$#keywords]->{'last'} = 1;
   return \@keywords;
}

=item get_keywords_json

Used for the sortable html table of keywords

=cut

##################################################
sub get_keywords_json {
##################################################
   my ($self, $c ) = @_;

   $c->request->params->{l} = 255;
   my $keywords = $self->get_keywords($c);

   my @keyword_list;
   foreach my $keyword(@{$keywords}) {
      push(@keyword_list, ["<input type='checkbox' name='keyword_".$keyword->id."' />",
                           $keyword->keyword, $keyword->demand, $keyword->supply, $keyword->profitability, 
                           $keyword->cpc, $keyword->keyworth ]);
   }

   my $json = JSON->new->allow_nonref;
   my $keywords_js_string = $json->encode( \@keyword_list );
   return $keywords_js_string;
}

=item get_keyword_list_js

Used for the autosuggest box

=cut

##################################################
sub get_keyword_list_js {
##################################################
   my ($self, $c, %params) = @_;

   $c->request->params->{l} = 2000;
   my $keywords = $self->get_keywords($c);

   my %associated_keywords = map { $_->id => 1 } @{$params{associated_keywords}};

   my $js = "";
   foreach my $keyword(@{$keywords}) {
      if(! $associated_keywords{$keyword->id}){
         $js .= "[".$keyword->id.", '".$keyword->keyword."'],";
      }
   }

   $js =~ s/,$//;

   return $js;
}

=item get_keywords_for_item

%params{table => $table_name, 
        table_id => $table_id}

=cut

##################################################
sub get_keywords_for_item {
##################################################
   my ($self, $c, %params) = @_;

   my @keyword_associations = $c->model('DB')->resultset('KeywordAssociation')->search(
         {
         which_table => { '=', $params{'table'} },
         table_id => { '=', $params{'table_id'} }
         }
   );

   if(! scalar(@keyword_associations)){
      return undef;
   }

   my @keyword_ids; my %keyword_associations;
   foreach my $kwd_ass(@keyword_associations) {
      push(@keyword_ids, $kwd_ass->keyword_id);
      $keyword_associations{$kwd_ass->keyword_id} = $kwd_ass->id;
   }

   my @keywords = $c->model('DB')->resultset('Keyword')->search(
         {
         id => { 'IN', \@keyword_ids }
         }
   );

   foreach my $k(@keywords) {
      $k->{keyword_association_id} = $keyword_associations{$k->id};
   }

   return \@keywords;
}

=item get_keywords_for_item_js

%params{table => $table_name, 
        table_id => $table_id}

=cut

##################################################
sub get_keywords_for_item_js {
##################################################
   my ($self, $c, %params) = @_;

   my $keywords;
   if($params{'associated_keywords'}){
      $keywords = $params{'associated_keywords'};
   }else{
      $keywords = $self->get_keywords_for_item($c, %params);
   }

   my @keyword_list;
   foreach my $keyword(@{$keywords}) {
      push(@keyword_list, [ $keyword->keyword, $keyword->demand, $keyword->supply, $keyword->profitability, $keyword->cpc ]);
   }

   my $json = JSON->new->allow_nonref;
   my $keywords_js_string = $json->encode( \@keyword_list );
   return $keywords_js_string;

}

=item propagate_keyword_associations_from_categories_to_playnow_games

=cut

##################################################
sub propagate_keyword_associations_from_categories_to_playnow_games {
##################################################
   my ($self, $c, %params) = @_;

   my @playnow_games = $c->model('DB')->resultset('Playnow')->search(
         {
         status => { '=', 1 }
         }
   );

   my $new_association;
   foreach my $playnow (@playnow_games) {
      my $categories = TodaysWord::Model::Category->get_categories_for_item($c, table => 'playnow', table_id => $playnow->id);

      my @category_ids;
      foreach my $category (@{$categories}) {
         push(@category_ids, $category->id);
      }
      my @keyword_associations = $c->model('DB')->resultset('KeywordAssociation')->search(
            {
            which_table => { '=', 'category' },
            table_id => { 'IN', \@category_ids }
            }
      );

      foreach my $association (@keyword_associations) {
         $new_association = $c->model('DB::KeywordAssociation')->find_or_create({
                                             keyword_id => $association->keyword_id,
                                             which_table => 'playnow',
                                             table_id => $playnow->id
                                          });
      }
   }
}


=head1 NAME

TodaysWord::Model::Keword - A play to keep the Keword DB subs

=head1 SYNOPSIS

See L<TodaysWord>

=head1 DESCRIPTION

TodaysWord::Model::Keword - A play to keep the Keword DB subs

=head1 AUTHOR


marilyn

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

