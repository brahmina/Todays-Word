package TodaysWord::Form::Playnow;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

has '+item_class' => ( default =>'Playnow' );

has_field 'game' => (maxlength => 30, required => 1);
has_field 'name' => (maxlength => 50, required => 1);
has_field 'code' => (type => 'TextArea', required => 1);

has_field 'blurb' => (maxlength => 85);
has_field 'meta_description' => (type => 'TextArea', rows => 3);
has_field 'description' => (type => 'TextArea', rows => 20);

has_field 'source' => (maxlength => 100);
has_field 'which' => ( type => "Hidden", default => "add" );

has '+name' => ( default =>'playnow' );
my $custom_submit = qq~<div class="button" id="submit_button">
        <a onclick="submitForm(document.playnow)" id="submit_todaysword">
            <img src="/static/images/icons/add.png" alt="Add Playnow Game" />
            <span>Add Game</span>
            </a>
        </div>
        <input type="submit" name="hsubmit" class="hidden_submit" /><br />~;

has 'custom_submit' => ( isa => 'Str', is => 'rw', default => $custom_submit);

__PACKAGE__->meta->make_immutable;
1;





