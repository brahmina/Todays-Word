use utf8;
package TodaysWord::Schema::Result::CrosswordWord;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodaysWord::Schema::Result::CrosswordWord

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

=head1 TABLE: C<crossword_word>

=cut

__PACKAGE__->table("crossword_word");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 crossword_id

  data_type: 'integer'
  is_nullable: 1

=head2 rel_id

  data_type: 'integer'
  is_nullable: 1

=head2 word

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 dict_word_id

  data_type: 'integer'
  is_nullable: 1

=head2 status

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 1

=head2 x

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 y

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "crossword_id",
  { data_type => "integer", is_nullable => 1 },
  "rel_id",
  { data_type => "integer", is_nullable => 1 },
  "word",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "dict_word_id",
  { data_type => "integer", is_nullable => 1 },
  "status",
  { data_type => "tinyint", default_value => 1, is_nullable => 1 },
  "x",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "y",
  { data_type => "varchar", is_nullable => 1, size => 10 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-11-20 06:29:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TWCm4xJ0ddJq0rDVWkEKWA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
