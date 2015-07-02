package TodaysWord::Form::Sudoku;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;
use HTML::FormHandler::Field::Upload;

has '+item_class' => ( default =>'Sudoku' );
has_field 'description' => (maxlength => 40);

has '+enctype' => ( default => 'multipart/form-data');
has_field 'file_location' => ( type => 'Upload' );

has '+name' => ( default =>'add_game' );
my $custom_submit = qq~<div class="button" id="submit_button">
        <a onclick="submitForm(document.add_game)" id="submit_crossword">
            <img src="/static/images/icons/add.png" alt="Add Sudoku" />
            <span>Add Sudoku</span>
            </a>
        </div>
        <input type="submit" name="hsubmit" class="hidden_submit" /><br />~;

has 'custom_submit' => ( isa => 'Str', is => 'rw', lazy => 1, default => $custom_submit);

__PACKAGE__->meta->make_immutable;
1;



