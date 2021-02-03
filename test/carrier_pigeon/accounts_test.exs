defmodule CarrierPigeon.AccountsTest do
  use CarrierPigeon.DataCase

  alias CarrierPigeon.Accounts

  describe "users" do
    alias CarrierPigeon.Accounts.User

    @created_user_password "abc123"

    @valid_attrs %{
      email: "some@email.com.br",
      name: "Cleber de Oliveira",
      password: @created_user_password,
      password_confirmation: @created_user_password,
      username: "destroyer123"
    }

    @updated_user_password "def123"

    @update_attrs %{
      email: "some.other@gmail.com",
      name: "José dos Santos",
      password: @updated_user_password,
      password_confirmation: @updated_user_password,
      username: "fallenAngel355"
    }

    @invalid_attrs %{
      email: "123"
    }

    def user_fixture() do
      {:ok, user} = Accounts.create_user(@valid_attrs)

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.user_id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert {:ok, user} == Argon2.check_pass(user, @created_user_password, hash_key: :password)
      assert user.username == "destroyer123"
    end


    test "create_user/1 with invalid data returns error changeset" do
      { :error, changeset } = Accounts.create_user(@invalid_attrs)
      assert changeset.valid? == false
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert {:ok, user} == Argon2.check_pass(user, @updated_user_password, hash_key: :password)
      assert user.username == "fallenAngel355"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      {:error, changeset} = Accounts.update_user(user, @invalid_attrs)
      assert changeset.valid? == false
      assert user == Accounts.get_user!(user.user_id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.user_id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "authenticate_user/2 returns ok on correct data" do
      user = user_fixture()
      password = @created_user_password

      { :ok, token } = Accounts.authenticate_user(user.email, password)

      assert is_binary(token)
    end

    test "authenticate_user/2 returns error on bad data" do
      user = user_fixture()
      password = "other_password123"
      assert { :error, :invalid_credentials } == Accounts.authenticate_user(user.email, password)
    end

  end
end
