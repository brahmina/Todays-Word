package TodaysWord::Form::Category;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

has '+item_class' => ( default =>'Category' );

has_field 'name' => (maxlength => 30, required => 1);
has_field 'link_text' => (maxlength => 50);
has_field 'meta_description' => (type => 'TextArea', rows => 3);
has_field 'article' => (type => 'TextArea', rows => 25);
has_field 'which' => ( type => "Hidden", default => "add" );


has '+name' => ( default =>'category' );
my $custom_submit = qq~<div class="button" id="submit_button">
        <a onclick="submitForm(document.category)" id="submit_category">
            <img src="/static/images/icons/add.png" alt="Add Category" />
            <span>Add Category</span>
            </a>
        </div>
        <input type="submit" name="hsubmit" class="hidden_submit" /><br />~;

has 'custom_submit' => ( isa => 'Str', is => 'rw', default => $custom_submit);

__PACKAGE__->meta->make_immutable;
1;





