use utf8;
package TodaysWord::Schema::Result::Transaction;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodaysWord::Schema::Result::Transaction

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

=head1 TABLE: C<transaction>

=cut

__PACKAGE__->table("transaction");

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

=head2 type

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 amount

  data_type: 'float'
  is_nullable: 1
  size: [9,2]

=head2 method

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 date_sent

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 success

  data_type: 'tinyint'
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
  "user_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "type",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "amount",
  { data_type => "float", is_nullable => 1, size => [9, 2] },
  "method",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "date_sent",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "success",
  { data_type => "tinyint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-11-20 06:29:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vW6xXMB1ipNs9P5PxPDofA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
