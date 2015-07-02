use utf8;
package TodaysWord::Schema::Result::CaptionBubble;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodaysWord::Schema::Result::CaptionBubble

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

=head1 TABLE: C<caption_bubble>

=cut

__PACKAGE__->table("caption_bubble");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 caption_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 class

  data_type: 'text'
  is_nullable: 1

=head2 width

  data_type: 'mediumint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 height

  data_type: 'mediumint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 top

  data_type: 'mediumint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 fromleft

  data_type: 'mediumint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 fontsize

  data_type: 'mediumint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 background

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 border

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 font

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 customcss

  data_type: 'varchar'
  is_nullable: 1
  size: 100

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
  "caption_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "class",
  { data_type => "text", is_nullable => 1 },
  "width",
  { data_type => "mediumint", extra => { unsigned => 1 }, is_nullable => 1 },
  "height",
  { data_type => "mediumint", extra => { unsigned => 1 }, is_nullable => 1 },
  "top",
  { data_type => "mediumint", extra => { unsigned => 1 }, is_nullable => 1 },
  "fromleft",
  { data_type => "mediumint", extra => { unsigned => 1 }, is_nullable => 1 },
  "fontsize",
  { data_type => "mediumint", extra => { unsigned => 1 }, is_nullable => 1 },
  "background",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "border",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "font",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "customcss",
  { data_type => "varchar", is_nullable => 1, size => 100 },
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

=head2 caption

Type: belongs_to

Related object: L<TodaysWord::Schema::Result::Caption>

=cut

__PACKAGE__->belongs_to(
  "caption",
  "TodaysWord::Schema::Result::Caption",
  { id => "caption_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 caption_entries

Type: has_many

Related object: L<TodaysWord::Schema::Result::CaptionEntry>

=cut

__PACKAGE__->has_many(
  "caption_entries",
  "TodaysWord::Schema::Result::CaptionEntry",
  { "foreign.caption_bubble_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-11-20 06:29:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fe4BFUK4VKXGQGv/gy388A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
