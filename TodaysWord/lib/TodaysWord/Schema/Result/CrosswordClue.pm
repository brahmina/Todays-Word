use utf8;
package TodaysWord::Schema::Result::CrosswordClue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodaysWord::Schema::Result::CrosswordClue

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

=head1 TABLE: C<crossword_clue>

=cut

__PACKAGE__->table("crossword_clue");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 crossword_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 number

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 across_or_down

  data_type: 'char'
  is_nullable: 1
  size: 1

=head2 clue

  data_type: 'varchar'
  is_nullable: 1
  size: 40

=head2 word_id

  data_type: 'integer'
  extra: {unsigned => 1}
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
  "crossword_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "number",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "across_or_down",
  { data_type => "char", is_nullable => 1, size => 1 },
  "clue",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "word_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
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

=head1 RELATIONS

=head2 crossword

Type: belongs_to

Related object: L<TodaysWord::Schema::Result::Crossword>

=cut

__PACKAGE__->belongs_to(
  "crossword",
  "TodaysWord::Schema::Result::Crossword",
  { id => "crossword_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-11-20 06:29:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:V2aKDX/VronWFP7XQdNusA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
