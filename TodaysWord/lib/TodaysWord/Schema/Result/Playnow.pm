use utf8;
package TodaysWord::Schema::Result::Playnow;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodaysWord::Schema::Result::Playnow

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

=head1 TABLE: C<playnow>

=cut

__PACKAGE__->table("playnow");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 game

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 seo_name

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 meta_description

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 sort_order

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 blurb

  data_type: 'varchar'
  is_nullable: 1
  size: 85

=head2 code

  data_type: 'text'
  is_nullable: 1

=head2 width

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 height

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 source

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 status

  data_type: 'tinyint'
  default_value: 1
  extra: {unsigned => 1}
  is_nullable: 1

=head2 releasable

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

=head2 rating

  data_type: 'float'
  default_value: 0.00
  extra: {unsigned => 1}
  is_nullable: 1
  size: [5,2]

=head2 rating_count

  data_type: 'integer'
  default_value: 0
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
  "game",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "seo_name",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "meta_description",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "sort_order",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "blurb",
  { data_type => "varchar", is_nullable => 1, size => 85 },
  "code",
  { data_type => "text", is_nullable => 1 },
  "width",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "height",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "source",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "status",
  {
    data_type => "tinyint",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "releasable",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "rating",
  {
    data_type => "float",
    default_value => "0.00",
    extra => { unsigned => 1 },
    is_nullable => 1,
    size => [5, 2],
  },
  "rating_count",
  {
    data_type => "integer",
    default_value => 0,
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

=head2 playnow_ratings

Type: has_many

Related object: L<TodaysWord::Schema::Result::PlaynowRating>

=cut

__PACKAGE__->has_many(
  "playnow_ratings",
  "TodaysWord::Schema::Result::PlaynowRating",
  { "foreign.playnow_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-11-20 06:29:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:M0CiYCeR2R1CQrrLRvZ1+g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
