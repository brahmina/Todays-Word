package TodaysWord::Form::Advert;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

has '+item_class' => ( default =>'Advert' );
has_field 'source' => (type => 'Text', maxlength => 50, required => 1);
has_field 'code' => (type => 'TextArea', required => 1);
has_field 'width' => (type => 'Text', maxlength => 4, required => 1);
has_field 'height' => (type => 'Text', maxlength => 4, required => 1);
has_field 'status' => ( type => 'Select' );
sub options_status {
    return (
        1   => 'running',
        2   => 'off',
        0   => 'deleted',
    );
}



has '+name' => ( default =>'advert' );
my $custom_submit = qq~<div class="button" id="submit_advert">
        <a onclick="submitForm(document.advert)" id="submit_advert_a">
            <img src="/static/images/icons/add.png" alt="Add " />
            <span>Add advert</span>
            </a>
        </div>
        <input type="submit" name="hsubmit" class="hidden_submit" /><br />~;

has 'custom_submit' => ( isa => 'Str', is => 'rw', lazy => 1, default => $custom_submit);

__PACKAGE__->meta->make_immutable;
1;


