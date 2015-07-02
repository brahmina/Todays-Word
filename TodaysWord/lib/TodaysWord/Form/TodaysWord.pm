package TodaysWord::Form::TodaysWord;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

has '+item_class' => ( default =>'TodaysWord' );
has_field 'word' => (maxlength => 30);
has_field 'clue1' => (maxlength => 50);
has_field 'clue2' => (maxlength => 50);
has_field 'clue3' => (maxlength => 50);
has_field 'clue4' => (maxlength => 50);
has_field 'clue5' => (maxlength => 50);
has_field 'dict_word_id' => (type => 'Hidden');

has '+name' => ( default =>'add_game' );
my $custom_submit = qq~<div class="button" id="submit_todaysword">
        <a onclick="submitForm(document.add_game)" id="submit_todaysword_a">
            <img src="/static/images/icons/add.png" alt="Add Today's Word" />
            <span>Add Word</span>
            </a>
        </div>
        <input type="submit" name="hsubmit" class="hidden_submit" /><br />~;

has 'custom_submit' => ( isa => 'Str', is => 'rw', lazy => 1, default => $custom_submit);

__PACKAGE__->meta->make_immutable;
1;



