use utf8;
package TodaysWord::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodaysWord::Schema::Result::User

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

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 password

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 email_address

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 full_name

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 active

  data_type: 'tinyint'
  default_value: 1
  extra: {unsigned => 1}
  is_nullable: 1

=head2 status

  data_type: 'tinyint'
  default_value: 1
  extra: {unsigned => 1}
  is_nullable: 1

=head2 public_profile

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 1

=head2 admin

  data_type: 'tinyint'
  default_value: 0
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
  "username",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "password",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "email_address",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "full_name",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "active",
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
  "public_profile",
  { data_type => "tinyint", default_value => 1, is_nullable => 1 },
  "admin",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 acro_phrases

Type: has_many

Related object: L<TodaysWord::Schema::Result::AcroPhrase>

=cut

__PACKAGE__->has_many(
  "acro_phrases",
  "TodaysWord::Schema::Result::AcroPhrase",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ad_impressions

Type: has_many

Related object: L<TodaysWord::Schema::Result::AdImpression>

=cut

__PACKAGE__->has_many(
  "ad_impressions",
  "TodaysWord::Schema::Result::AdImpression",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 caption_entries

Type: has_many

Related object: L<TodaysWord::Schema::Result::CaptionEntry>

=cut

__PACKAGE__->has_many(
  "caption_entries",
  "TodaysWord::Schema::Result::CaptionEntry",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 playnow_ratings

Type: has_many

Related object: L<TodaysWord::Schema::Result::PlaynowRating>

=cut

__PACKAGE__->has_many(
  "playnow_ratings",
  "TodaysWord::Schema::Result::PlaynowRating",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_roles

Type: has_many

Related object: L<TodaysWord::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "TodaysWord::Schema::Result::UserRole",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-11-20 06:29:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NlDfy/aNV9kfmv4lH+Vf7w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
