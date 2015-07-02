package TodaysWord::Form::Acro;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

has '+item_class' => ( default =>'Acros' );
has_field 'number_of_letters' => (maxlength => 2, default => 8);

has '+name' => ( default =>'add_game' );
my $custom_submit = qq~<div class="button" id="submit_button">
        <a onclick="submitForm(document.add_game)" id="submit_todaysword">
            <img src="/static/images/icons/add.png" alt="Add Acro" />
            <span>Add Acro</span>
            </a>
        </div>
        <input type="submit" name="hsubmit" class="hidden_submit" /><br />~;

has 'custom_submit' => ( isa => 'Str', is => 'rw', lazy => 1, default => $custom_submit);

__PACKAGE__->meta->make_immutable;
1;





