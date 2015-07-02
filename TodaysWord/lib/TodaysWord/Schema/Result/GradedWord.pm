use utf8;
package TodaysWord::Schema::Result::GradedWord;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodaysWord::Schema::Result::GradedWord

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

=head1 TABLE: C<graded_words>

=cut

__PACKAGE__->table("graded_words");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 word

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 grade

  data_type: 'integer'
  is_nullable: 1

=head2 definition

  data_type: 'text'
  is_nullable: 1

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 lesson

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "word",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "grade",
  { data_type => "integer", is_nullable => 1 },
  "definition",
  { data_type => "text", is_nullable => 1 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "lesson",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-11-20 06:29:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:91wJZMeR3SLk8VuWFbkeVw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
