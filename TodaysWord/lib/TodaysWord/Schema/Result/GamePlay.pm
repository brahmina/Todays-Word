use utf8;
package TodaysWord::Schema::Result::GamePlay;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TodaysWord::Schema::Result::GamePlay

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

=head1 TABLE: C<game_play>

=cut

__PACKAGE__->table("game_play");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 game_table

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 game_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 ip

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 time_spent

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 real_time

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 start_time

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 end_time

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 score

  data_type: 'float'
  extra: {unsigned => 1}
  is_nullable: 1
  size: [8,3]

=head2 extra

  data_type: 'text'
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
  "game_table",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "game_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "user_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "ip",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "time_spent",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "real_time",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "start_time",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "end_time",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "score",
  {
    data_type => "float",
    extra => { unsigned => 1 },
    is_nullable => 1,
    size => [8, 3],
  },
  "extra",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 game_timers

Type: has_many

Related object: L<TodaysWord::Schema::Result::GameTimer>

=cut

__PACKAGE__->has_many(
  "game_timers",
  "TodaysWord::Schema::Result::GameTimer",
  { "foreign.game_play_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-11-20 06:29:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YiEsimpLnvrcAx4A21wtsg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
