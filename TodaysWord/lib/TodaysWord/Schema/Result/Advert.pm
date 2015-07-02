use utf8;
package TodaysWord::Schema::Result::Advert;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodaysWord::Schema::Result::Advert

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

=head1 TABLE: C<advert>

=cut

__PACKAGE__->table("advert");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 source

  data_type: 'varchar'
  is_nullable: 1
  size: 20

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

=head2 create_date

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
  "source",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "code",
  { data_type => "text", is_nullable => 1 },
  "width",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "height",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "create_date",
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

=head2 ad_impressions

Type: has_many

Related object: L<TodaysWord::Schema::Result::AdImpression>

=cut

__PACKAGE__->has_many(
  "ad_impressions",
  "TodaysWord::Schema::Result::AdImpression",
  { "foreign.advert_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-11-20 06:29:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JGZB/43aCwBCSXxi83kyzQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
