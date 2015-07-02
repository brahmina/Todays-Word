package TodaysWord::Form::Article;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

has '+item_class' => ( default =>'Category' );

has_field 'headline' => (maxlength => 200, required => 1);
has_field 'name_for_url' => (maxlength => 200, required => 1);
has_field 'aim' => (maxlength => 200, required => 1);
has_field 'audience' => (maxlength => 200, required => 1);

sub options_written_where {
       return (
           'Intentional Lottery Numbers' => 'Intentional Lottery Numbers'
       );
   }

has_field 'content' => (type => 'TextArea', rows => 25);
has_field 'which' => ( type => "Hidden", default => "add" );
has_field 'teaser' => (type => 'TextArea', rows => 5);
has_field 'table' => ( type => "Hidden", default => "article" );
has_field 'id' => ( type => "Hidden" );

has '+name' => ( default =>'article' );
my $custom_submit = qq~<div class="button" id="article_add_submit_button">
        <a onclick="submitForm(document.article)" id="submit_article">
            <img src="/static/images/icons/add.png" alt="Add Article" />
            <span>Add Article</span>
            </a>
        </div>
        <input type="submit" name="hsubmit" class="hidden_submit" /><br />~;

has 'custom_submit' => ( isa => 'Str', is => 'rw', default => $custom_submit);

__PACKAGE__->meta->make_immutable;
1;





