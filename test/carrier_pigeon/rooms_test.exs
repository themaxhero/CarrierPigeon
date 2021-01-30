defmodule CarrierPigeon.RoomsTest do
  use CarrierPigeon.DataCase

  alias CarrierPigeon.Rooms

  describe "rooms" do
    alias CarrierPigeon.Rooms.Room

    @valid_private_attrs %{
      type: :pm,
      member_ids: []
    }

    @update_private_attrs %{
      type: :pm
      member_ids: []
    }

    @invalid_private_attrs %{}

    @valid_group_attrs %{
      name: "Some test room",
      owner_id: owner_profile_id,
      type: :group,
      member_ids: []
    }

    @update_group_attrs %{

    }

    @invalid_group_attrs %{}

    def room_fixture(attrs \\ %{}) do
      {:ok, room} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Rooms.create_room

      room
    end

    test "list_rooms/1 returns all chat rooms for a user" do

    end

    test "get_room!/1 returns the room with given id" do
      room = room_fixture()
      assert Rooms.get_room!(room.room_id) == room
    end

    test "get_room/1 returns the room with given id" do
      old_room = room_fixture()
      { :ok, room } Rooms.get_room(old_room.room_id)
      assert old_room == room
    end

    test "create_room/1 with valid data creates a room" do

    end

    test "is_user_in_room?/2 returns true if the user is a member of the chat room" do

    end

    test "is_user_in_room?/2 returns false if the user is not a member of the chat room" do

    end

    test "insert_meessage/3 inserts a message in the room" do

    end
  end

end
