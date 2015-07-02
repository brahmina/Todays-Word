use utf8;
package TodaysWord::Schema::Result::TodaysWordGuess;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodaysWord::Schema::Result::TodaysWordGuess

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::EncodedColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "EncodedColumn");

=head1 TABLE: C<todays_word_guess>

=cut

__PACKAGE__->table("todays_word_guess");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 todays_word_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 ip

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 guess

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 create_date

  data_type: 'integer'
  is_nullable: 1

=head2 status

  data_type: 'tinyint'
  default_value: 1
  extra: {unsigned => 1}
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "todays_word_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "user_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "ip",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "guess",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "create_date",
  { data_type => "integer", is_nullable => 1 },
  "status",
  {
    data_type => "tinyint",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-11-20 06:29:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:p28nkMnPD9T6wzokZi+PVg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
