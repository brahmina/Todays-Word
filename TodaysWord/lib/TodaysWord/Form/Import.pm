package TodaysWord::Form::Import;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;
use HTML::FormHandler::Field::Upload;

has '+item_class' => ( default => 'Import' );
has_field 'name' => (maxlength => 40);

has '+enctype' => ( default => 'multipart/form-data');
has_field 'file_location' => ( type => 'Upload' );

has '+name' => ( default =>'add_import' );
my $custom_submit = qq~<div class="button" id="submit_button">
        <a onclick="submitForm(document.add_import)" id="submit_import">
            <img src="/static/images/icons/add.png" alt="Import" />
            <span>Import</span>
            </a>
        </div>
        <input type="submit" name="hsubmit" class="hidden_submit" /><br />~;

has 'custom_submit' => ( isa => 'Str', is => 'rw', lazy => 1, default => $custom_submit);

__PACKAGE__->meta->make_immutable;
1;



