use utf8;
package TodaysWord::Schema::Result::TodaysWord;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodaysWord::Schema::Result::TodaysWord

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

=head1 TABLE: C<todays_word>

=cut

__PACKAGE__->table("todays_word");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 word

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 dict_word_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 clue1

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 clue2

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 clue3

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 clue4

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 clue5

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 create_date

  data_type: 'integer'
  is_nullable: 1

=head2 scheduled_date

  data_type: 'integer'
  is_nullable: 1

=head2 played_date

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
  "word",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "dict_word_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "clue1",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "clue2",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "clue3",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "clue4",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "clue5",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "create_date",
  { data_type => "integer", is_nullable => 1 },
  "scheduled_date",
  { data_type => "integer", is_nullable => 1 },
  "played_date",
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5wEes957+FjUYiaiiJVZog


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
