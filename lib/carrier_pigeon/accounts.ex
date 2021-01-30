defmodule CarrierPigeon.Accounts do
  @moduledoc """
  The Accounts context.
  """
  alias CarrierPigeon.Repo
  alias CarrierPigeon.Guardian

  alias CarrierPigeon.Accounts.User
  alias User.Query, as: UserQuery
  alias Argon2

  defp autenticate_user_verify_pass(nil, _),
    do: { :error, :invalid_credentials }
  defp autenticate_user_verify_pass(user, password) do
    if Argon2.verify_pass(password, user.password) do
      { :ok, token, _ } = Guardian.encode_and_sign(user, %{})

      { :ok, token }
    else
      { :error, :invalid_credentials }
    end
  end

  def authenticate_user(login, password) do
    login
    |> UserQuery.query_user_by_email
    |> Repo.one
    |> autenticate_user_verify_pass(password)
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_user(map()) ::
  { :ok, User.t() }
  | { :error, any() }
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_user(User.t(), map()) ::
  { :ok, User.t() }
  | { :error, any() }
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_user(User.t()) ::
  { :ok, User.t() }
  | { :error, any() }
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_user(User.t(), map()) :: User.changeset
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
