use utf8;
package TodaysWord::Schema::Result::UserInfo;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodaysWord::Schema::Result::UserInfo

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

=head1 TABLE: C<user_info>

=cut

__PACKAGE__->table("user_info");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 country_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 region_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 avatar_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 city

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 bio

  data_type: 'blob'
  is_nullable: 1

=head2 gender

  data_type: 'char'
  is_nullable: 1
  size: 1

=head2 birth_day

  data_type: 'integer'
  default_value: 1
  extra: {unsigned => 1}
  is_nullable: 1

=head2 birth_month

  data_type: 'integer'
  default_value: 1
  extra: {unsigned => 1}
  is_nullable: 1

=head2 birth_year

  data_type: 'integer'
  default_value: 1
  extra: {unsigned => 1}
  is_nullable: 1

=head2 receive_news

  data_type: 'tinyint'
  default_value: 1
  extra: {unsigned => 1}
  is_nullable: 1

=head2 receive_notifications

  data_type: 'tinyint'
  default_value: 1
  extra: {unsigned => 1}
  is_nullable: 1

=head2 status

  data_type: 'tinyint'
  default_value: 1
  extra: {unsigned => 1}
  is_nullable: 1

=head2 paypal

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 address

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 postal_code

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "user_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "country_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "region_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "avatar_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "city",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "bio",
  { data_type => "blob", is_nullable => 1 },
  "gender",
  { data_type => "char", is_nullable => 1, size => 1 },
  "birth_day",
  {
    data_type => "integer",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "birth_month",
  {
    data_type => "integer",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "birth_year",
  {
    data_type => "integer",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "receive_news",
  {
    data_type => "tinyint",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "receive_notifications",
  {
    data_type => "tinyint",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "status",
  {
    data_type => "tinyint",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "paypal",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "address",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "postal_code",
  { data_type => "varchar", is_nullable => 1, size => 10 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-11-20 06:29:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vNFtGXPQmLXXDeWSN9pmQw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
