use utf8;
package TodaysWord::Schema::Result::CaptionEntry;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodaysWord::Schema::Result::CaptionEntry

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

=head1 TABLE: C<caption_entry>

=cut

__PACKAGE__->table("caption_entry");

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

=head2 caption_bubble_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 ip

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 caption

  data_type: 'varchar'
  is_nullable: 1
  size: 250

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
  "caption_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "caption_bubble_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "user_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "ip",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "caption",
  { data_type => "varchar", is_nullable => 1, size => 250 },
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

=head2 caption_bubble

Type: belongs_to

Related object: L<TodaysWord::Schema::Result::CaptionBubble>

=cut

__PACKAGE__->belongs_to(
  "caption_bubble",
  "TodaysWord::Schema::Result::CaptionBubble",
  { id => "caption_bubble_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 user

Type: belongs_to

Related object: L<TodaysWord::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "TodaysWord::Schema::Result::User",
  { id => "user_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-11-20 06:29:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+tal0sOpjVlqXSNfNpVCxA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
