use utf8;
package TodaysWord::Schema::Result::Keyword;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodaysWord::Schema::Result::Keyword

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

=head1 TABLE: C<keyword>

=cut

__PACKAGE__->table("keyword");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 keyword

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 demand

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 supply

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 profitability

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 pcdm

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 cpc

  data_type: 'decimal'
  extra: {unsigned => 1}
  is_nullable: 0
  size: [9,2]

=head2 keyworth

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 status

  data_type: 'tinyint'
  default_value: 1
  extra: {unsigned => 1}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "keyword",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "demand",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "supply",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "profitability",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "pcdm",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "cpc",
  {
    data_type => "decimal",
    extra => { unsigned => 1 },
    is_nullable => 0,
    size => [9, 2],
  },
  "keyworth",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "status",
  {
    data_type => "tinyint",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-11-20 06:29:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kWaZYu5GYu+QI50DUxxTEA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
