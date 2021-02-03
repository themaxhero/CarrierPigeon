defmodule CarrierPigeon.Rooms.RoomMember do
  use Ecto.Schema

  alias CarrierPigeon.Profiles.Profile
  alias CarrierPigeon.Rooms.Room

  @primary_key { :room_member_id, :binary_id, autogenerate: true }

  schema "room_members" do
    belongs_to :member, Profile,
      foreign_key: :profile_id,
      references: :profile_id,
      type: :binary_id

    belongs_to :room, Room,
      foreign_key: :room_id,
      references: :room_id,
      type: :binary_id

    timestamps()
  end

end
