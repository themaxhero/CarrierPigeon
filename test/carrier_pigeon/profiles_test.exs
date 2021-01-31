defmodule CarrierPigeon.ProfilesTest do
  use CarrierPigeon.DataCase

  alias CarrierPigeon.Profiles

  describe "profiles" do
    alias CarrierPigeon.Profiles.Profile

    @profile_a_attrs %{
      nickname: "GreatSword",
      room_ids: []
    }

    @profile_b_attrs %{
      nickname: "MaSaMuNe",
      room_ids: []
    }

    def user_fixture_a() do
      attrs = %{
        email: "some@email.com.br",
        name: "Cleber de Oliveira",
        password: "abc123!@#123",
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
        username: "fallenAngel355"
      }

      {:ok, user} = Accounts.create_user(attrs)

      user
    end

    def profile_fixture_a(user_id) do
      attrs = %{ @profile_a_attrs | owner_id: user_id }
      Profiles.create_profile(attrs)
    end

    def profile_fixture_b(user_id) do
      attrs = %{ @profile_b_attrs | owner_id: user_id }
      Profiles.create_profile(attrs)
    end

    test "get_profile/1 with valid data creates a profile" do
      user = user_fixture_a()
      profile = profile_fixture_a(user.user_id)

      { :ok, fetched_profile } = Profiles.get_profile(profile.profile_id)

      assert profile == fetched_profile
    end

    test "get_profile!/1 with valid data creates a profile" do
      user = user_fixture_a()
      profile = profile_fixture_a(user.user_id)

      fetched_profile = Profiles.get_profile!(profile.profile_id)

      assert profile == fetched_profile
    end

    test "create_profile/1 with valid data creates a profile" do
      user = user_fixture_a()
      attrs = %{ @profile_a_attrs | owner_id: user.user_id }
      { :ok, profile } = Profiles.create_profile(attrs)

      assert profile.nickname == @profile_a_attrs.nickname
      assert profile.user.user_id == @profile_a_attrs.user.user_id
    end

    test "create_profile!/1 with valid data creates a profile" do
      user = user_fixture_a()
      attrs = %{ @profile_a_attrs | owner_id: user.user_id }
      profile = Profiles.create_profile!(attrs)

      assert profile != nil
      assert profile.nickname == @profile_a_attrs.nickname
      assert profile.user.user_id == @profile_a_attrs.user.user_id
    end

    test "update_profiles/2 with valid data updates given profile" do
      user = user_fixture_a()
      profile = profile_fixture_a(user.user_id)

      { :ok, profile } = Profiles.update_profile(profile.profile_id, @profile_b_attrs)

      assert profile.nickname == @profile_b_attrs.nickname
      assert profile.user.user_id == user.user_id
    end

    test "update_profiles!/2 with valid data updates given profile" do
      user = user_fixture_a()
      profile = profile_fixture_a(user.user_id)

      profile = Profiles.update_profile!(profile.profile_id, @profile_b_attrs)

      assert profile.nickname == @profile_b_attrs.nickname
      assert profile.user.user_id == user.user_id
    end

    test "delete_profile/1 deletes by giving the `profile_id`" do
      user = user_fixture_a()
      profile = profile_fixture_a(user.user_id)

      { :ok, profile } = Profiles.delete_profile(profile.profile_id)

      assert Profiles.get_profile!(profile.profile_id) == nil
    end

    test "delete_profile/1 deletes by giving the Profile struct" do
      user = user_fixture_a()
      profile = profile_fixture_a(user.user_id)

      { :ok, profile } = Profiles.delete_profile(profile)

      assert Profiles.get_profile!(profile.profile_id) == nil
    end

    test "delete_profile!/1 deletes by giving the `profile_id`" do
      user = user_fixture_a()
      profile = profile_fixture_a(user.user_id)
      profile = Profiles.delete_profile!(profile.profile_id)

      assert Profiles.get_profile!(profile.profile_id) == nil
    end

    test "delete_profile!/1 deletes by giving the Profile struct" do
      user = user_fixture_a()
      profile = profile_fixture_a(user.user_id)
      profile = Profiles.delete_profile!(profile)

      assert Profiles.get_profile!(profile.profile_id) == nil
    end
  end
end
