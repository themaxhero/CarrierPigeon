defmodule CarrierPigeon.RoomsTest do
  use CarrierPigeon.DataCase

  alias CarrierPigeon.Rooms

  describe "rooms" do
    alias CarrierPigeon.Accounts
    alias CarrierPigeon.Profiles

    @valid_private_attrs %{
      type: :pm,
    }

    # @update_private_attrs %{
    #   type: :pm,
    #   member_ids: [],
    # }

    # @invalid_private_attrs %{
    #   type: :johnson,
    #   member_ids: [1, 2, 3, 4],
    # }

    # @invalid_group_attrs %{
    #   type: :cleber,
    #   member_ids: [ 1, 2, 3, 4, 5, 6 ],
    # }

    def valid_group_attrs do
      user = user_fixture_group_owner()
      profile_room_owner = profile_room_owner_fixture(user.user_id)

      payload = %{
        name: "Some test room",
        owner: profile_room_owner,
        type: :group,
      }

      payload
    end

    def update_group_attrs do
      user_gp1 = user_fixture_group_1()
      user_gp2 = user_fixture_group_2()
      profile_group_1 = profile_room_group_fixture(user_gp1.user_id)
      profile_group_2 = profile_room_group_fixture(user_gp2.user_id)
      members = [
        profile_group_1,
        profile_group_2
      ]

      payload = %{
        type: :group,
      }

      payload
    end

    def room_pm_fixture(profile, members, attrs \\ %{}) do
      attrs =
        attrs
        |> Enum.into(@valid_private_attrs)

      {:ok, room} = Rooms.create_room(profile, members, attrs)

      room
    end

    def room_gp_fixture(profile, members, attrs \\ %{}) do
      attrs =
        attrs
        |> Enum.into(@valid_private_attrs)

      {:ok, room} = Rooms.create_room(profile, members, attrs)

      room
    end

    def profile_fixture_a(user_id) do
      user = Accounts.get_user!(user_id)
      attrs = %{
        nickname: "GreatSword",
        owner: user
      }

      { :ok, profile } = Profiles.create_profile(attrs)

      profile
    end

    def profile_fixture_b(user_id) do
      user = Accounts.get_user!(user_id)
      attrs = %{
        nickname: "MaSaMuNe",
        owner: user
      }

      { :ok, profile } = Profiles.create_profile(attrs)

      profile
    end

    def profile_room_owner_fixture(user_id) do
      user = Accounts.get_user!(user_id)
      attrs = %{
        nickname: "GreatSword",
        owner: user
      }

      { :ok, profile } = Profiles.create_profile(attrs)

      profile
    end

    def profile_room_group_fixture(user_id) do
      user = Accounts.get_user!(user_id)
      attrs = %{
        nickname: "Angra",
        owner: user
      }

      { :ok, profile } = Profiles.create_profile(attrs)

      profile
    end

    def user_fixture_a() do
      attrs = %{
        email: "some@email.com.br",
        name: "Cleber de Oliveira",
        password: "abc123!@#123",
        password_confirmation: "abc123!@#123",
        username: "destroyer123"
      }

      {:ok, user} = Accounts.create_user(attrs)

      user
    end

    def user_fixture_b() do
      attrs = %{
        email: "some.other@gmail.com",
        name: "José dos Santos",
        password: "0831#!G!13109",
        password_confirmation: "0831#!G!13109",
        username: "fallenAngel355"
      }

      {:ok, user} = Accounts.create_user(attrs)

      user
    end

    def user_fixture_group_owner() do
      attrs = %{
        email: "bossa_do_paulista@gmail.com",
        name: "Meu final de placa é dois",
        password: "0831#!G!13109",
        password_confirmation: "0831#!G!13109",
        username: "__Teste__"
      }

      {:ok, user} = Accounts.create_user(attrs)

      user
    end

    def user_fixture_group_1() do
      attrs = %{
        email: "carreta_caiu@gmail.com",
        name: "Carreta Caiu",
        password: "0831#!G!13109",
        password_confirmation: "0831#!G!13109",
        username: "recalculando_rota"
      }

      {:ok, user} = Accounts.create_user(attrs)

      user
    end

    def user_fixture_group_2() do
      attrs = %{
        email: "marginal_parou@gmail.com",
        name: "Patrão tá com pressa",
        password: "m0t0boy.c@i",
        password_confirmation: "m0t0boy.c@i",
        username: "aiaiaiai"
      }

      {:ok, user} = Accounts.create_user(attrs)

      user
    end

    test "list_rooms/1 returns all chat rooms for a user" do
      %{user_id: user_id} = user_fixture_a()
      profile = profile_fixture_a(user_id)

      %{ profile_id: profile_id } = profile
      rooms = Rooms.list_rooms(profile_id)

      assert Enum.all?(rooms, &(profile in &1.members))
    end

    test "get_room/1 returns the room with given id" do
      old_room = room_pm_fixture()
      { :ok, room } = Rooms.get_room(old_room.room_id)
      assert old_room == room
    end

    test "get_room!/1 returns the room with given id" do
      room = room_pm_fixture()
      assert Rooms.get_room!(room.room_id) == room
    end

    test "create_room/1 with valid data creates a private room" do
      user_a = user_fixture_a()
      user_b = user_fixture_b()
      profile_a = profile_fixture_a(user_a.user_id)
      profile_b = profile_fixture_b(user_b.user_id)
      payload = %{
        type: :pm,
        members: [ profile_a, profile_b ],
      }
      {:ok, room} = Rooms.create_room(payload)

      assert room.type == :pm
      assert profile_a in room.members
      assert profile_b in room.members
    end

    test "create_room!/1 with valid data creates a private room" do
      user_a = user_fixture_a()
      user_b = user_fixture_b()
      profile_a = profile_fixture_a(user_a.user_id)
      profile_b = profile_fixture_b(user_b.user_id)

      payload = %{
        type: :pm,
      }

      room = Rooms.create_room!(profile_a, payload)

      assert room.type == :pm
      assert profile_a in room.members
      assert profile_b in room.members
    end

    test "update_room/2 with valid data creates a private room" do
      user_a = user_fixture_a()
      user_b = user_fixture_b()
      profile_a = profile_fixture_a(user_a.user_id)
      profile_b = profile_fixture_b(user_b.user_id)

      room = room_pm_fixture()
      %{ room_id: room_id } = room

      payload = %{
        type: :pm,
        member_ids: [ profile_a.profile_id, profile_b.profile_id ],
      }

      {:ok, room} = Rooms.update_room(room_id, payload)

      assert room.type == :pm
      assert profile_a in room.members
      assert profile_b in room.members
    end

    test "update_room!/2 with valid data creates a private room" do
      user_a = user_fixture_a()
      user_b = user_fixture_b()
      profile_a = profile_fixture_a(user_a.user_id)
      profile_b = profile_fixture_b(user_b.user_id)

      room = room_pm_fixture()
      %{ room_id: room_id } = room

      payload = %{
        type: :pm,
        member_ids: [ profile_a.profile_id, profile_b.profile_id ],
      }

      room = Rooms.update_room!(room_id, payload)

      assert room.type == :pm
      assert profile_a in room.members
      assert profile_b in room.members
    end

    test "delete_room/1 with existing room deletes it." do
      room = room_pm_fixture()

      %{ room_id: room_id } = room

      { :ok, _ } = Rooms.delete_room(room_id)

      assert Rooms.get_room!(room_id) == nil
    end

    test "delete_room!/1 with existing room deletes it." do
      room = room_pm_fixture()

      %{ room_id: room_id } = room

      _ = Rooms.delete_room!(room_id)

      assert Rooms.get_room!(room_id) == nil
    end

    test "is_user_in_room?/2 returns true if the user is a member of the chat room" do
      room = room_pm_fixture()
      user = user_fixture_a()
      profile = profile_fixture_a(user.user_id)
      members = [ profile | room.members ]
      attrs = %{ members: members }

      %{ room_id: room_id } = room
      %{ profile_id: profile_id } = profile

      { :ok, _ } = Rooms.update_room(room_id, attrs)

      assert Rooms.is_user_in_room?(room_id, profile_id) == true
    end

    test "is_user_in_room?/2 returns false if the user is not a member of the chat room" do
      room = room_pm_fixture()
      user = user_fixture_a()
      profile = profile_fixture_a(user.user_id)

      %{ room_id: room_id } = room
      %{ profile_id: profile_id } = profile

      assert Rooms.is_user_in_room?(room_id, profile_id) == false
    end

    test "insert_message/3 inserts a message in the room" do
      room = room_pm_fixture()
      user = user_fixture_a()
      profile = profile_fixture_a(user.user_id)
      content = "Some test message"

      %{ room_id: room_id } = room
      %{ profile_id: profile_id } = profile

      { :ok, msg } = Rooms.insert_message(room_id, content, profile_id)

      assert msg.room.room_id == room_id
      assert msg.content == content
      assert msg.sender.profile_id == profile_id
    end
  end
end
