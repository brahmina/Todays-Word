use utf8;
package TodaysWord::Schema::Result::DictWord;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodaysWord::Schema::Result::DictWord

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

=head1 TABLE: C<dict_word>

=cut

__PACKAGE__->table("dict_word");

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

=head2 definition

  data_type: 'text'
  is_nullable: 1

=head2 synonym

  data_type: 'text'
  is_nullable: 1

=head2 frequency

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 etymology

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 status

  data_type: 'tinyint'
  default_value: 1
  extra: {unsigned => 1}
  is_nullable: 1

=head2 definition_wiki

  data_type: 'text'
  is_nullable: 1

=head2 word_orig

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 common

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

=head2 rating

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 todayswordworthy

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
  "definition",
  { data_type => "text", is_nullable => 1 },
  "synonym",
  { data_type => "text", is_nullable => 1 },
  "frequency",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "etymology",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "status",
  {
    data_type => "tinyint",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "definition_wiki",
  { data_type => "text", is_nullable => 1 },
  "word_orig",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "common",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "rating",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "todayswordworthy",
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


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-11-20 06:29:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lIuUQdDChzcrD872WdB2wQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
