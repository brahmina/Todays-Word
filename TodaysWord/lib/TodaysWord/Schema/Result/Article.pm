use utf8;
package TodaysWord::Schema::Result::Article;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodaysWord::Schema::Result::Article

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

=head1 TABLE: C<article>

=cut

__PACKAGE__->table("article");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 title

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 content

  data_type: 'text'
  is_nullable: 0

=head2 written_where

  data_type: 'varchar'
  is_nullable: 0
  size: 20

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
  "title",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "content",
  { data_type => "text", is_nullable => 0 },
  "written_where",
  { data_type => "varchar", is_nullable => 0, size => 20 },
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yPUAThJWIBviBC1rZPPHvw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;