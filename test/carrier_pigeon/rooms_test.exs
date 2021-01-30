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

    @invalid_private_attrs %{
      type: :johnson,
      member_ids: [1, 2, 3, 4]
    }

    @valid_group_attrs %{
      name: "Some test room",
      owner_id: owner_profile_id,
      type: :group,
      member_ids: []
    }

    @update_group_attrs %{
      type: :group,
      member_ids: [
        profile_a.profile_id,
        profile_b.profile_id
      ]
    }

    @invalid_group_attrs %{
      type: :cleber,
      member_ids: [ 1, 2, 3, 4, 5, 6 ]
    }

    def room_pm_fixture(attrs \\ %{}) do
      {:ok, room} =
        attrs
        |> Enum.into(@valid_private_attrs)
        |> Rooms.create_room

      room
    end

    def room_gp_fixture(attrs \\ %{}) do
      {:ok, room} =
        attrs
        |> Enum.into(@valid_group_attrs)
        |> Rooms.create_room

      room
    end

    def profile_fixture_a(user_id) do
      attrs = %{
        nickname: "GreatSword",
        room_ids: [],
        owner_id: user_id
      }

      Profiles.create_profile(attrs)
    end

    def profile_fixture_b(user_id) do
      attrs = %{
        nickname: "MaSaMuNe",
        room_ids: [],
        owner_id: user_id
      }

      Profiles.create_profile(attrs)
    end

    test "list_rooms/1 returns all chat rooms for a user" do
      profile = profile_fixture_a()

      %{ profile_id: profile_id } = profile
      rooms = list_rooms(profile_id)

      assert Enum.all?(rooms, &(profile in &1.members))
    end

    test "get_room!/1 returns the room with given id" do
      room = room_pm_fixture()
      assert Rooms.get_room!(room.room_id) == room
    end

    test "get_room/1 returns the room with given id" do
      old_room = room_pm_fixture()
      { :ok, room } Rooms.get_room(old_room.room_id)
      assert old_room == room
    end

    test "create_room/1 with valid data creates a private room" do
      payload = %{
        type: :pm,
        member_ids: [ profile_a.profile_id, profile_b.profile_id ],
      }
      {:ok, room} = Rooms.create_room(payload)

      assert room.type == :pm
      assert profile_a in room.members
      assert profile_b in room.members
    end

    test "is_user_in_room?/2 returns true if the user is a member of the chat room" do
      room = room_pm_fixture()
      profile = profile_fixture_a()
      members = [ profile | room.members ]
      attrs = %{ members: members }

      %{ room_id: room_id } = room
      %{ profile_id: profile_id } = profile

      { :ok, room } == Rooms.update_room(room_id, attrs)

      assert Rooms.is_user_in_room?(room_id, profile_id) == true
    end

    test "is_user_in_room?/2 returns false if the user is not a member of the chat room" do
      room = room_pm_fixture()
      profile = profile_fixture_a()

      %{ room_id: room_id } = room
      %{ profile_id: profile_id } = profile

      assert Rooms.is_user_in_room?(room_id, profile_id) == false
    end

    test "insert_meessage/3 inserts a message in the room" do
      room = room_pm_fixture()
      profile = profile_fixture_a()
      content = "Some test message"

      %{ room_id: room_id } = room
      %{ profile_id: profile_id } = profile

      { :ok, msg } = Rooms.insert_message(room_id, content, sender_id)

      assert msg.room.room_id == room_id
      assert msg.content == content
      assert msg.owner.profile_id == profile_id
    end
  end
end
