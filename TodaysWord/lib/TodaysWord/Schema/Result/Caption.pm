use utf8;
package TodaysWord::Schema::Result::Caption;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodaysWord::Schema::Result::Caption

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

=head1 TABLE: C<caption>

=cut

__PACKAGE__->table("caption");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 title

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 original_location

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 optimized_location

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 source

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 width

  data_type: 'integer'
  is_nullable: 1

=head2 height

  data_type: 'integer'
  is_nullable: 1

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
  "title",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "original_location",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "optimized_location",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "source",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "width",
  { data_type => "integer", is_nullable => 1 },
  "height",
  { data_type => "integer", is_nullable => 1 },
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

=head1 RELATIONS

=head2 caption_bubbles

Type: has_many

Related object: L<TodaysWord::Schema::Result::CaptionBubble>

=cut

__PACKAGE__->has_many(
  "caption_bubbles",
  "TodaysWord::Schema::Result::CaptionBubble",
  { "foreign.caption_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 caption_entries

Type: has_many

Related object: L<TodaysWord::Schema::Result::CaptionEntry>

=cut

__PACKAGE__->has_many(
  "caption_entries",
  "TodaysWord::Schema::Result::CaptionEntry",
  { "foreign.caption_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-11-20 06:29:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7cbX6BzOVFcMwUSASczqSg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
