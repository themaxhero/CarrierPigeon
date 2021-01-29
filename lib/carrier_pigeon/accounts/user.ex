defmodule CarrierPigeon.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Argon2

  @primary_key { :user_id, :binary_id, autogenerate: true }

  @casting_fields [:name, :username, :password, :password_confirmation, :email]
  @required_fields [:name, :username, :password, :password_confirmation, :email]

  @email_regexp ~r/^[\w.+\-]+@((?!-)[A-Za-z0–9-]{1, 63}(?<!-)\.)+[A-Za-z]{2, 6}$/

  @name_regexp ~r/^\w{2,}$/

  @username_regexp ~r/^[A-Za-z0-9_\-\.]{4,32}$/

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string
    field :username, :string

    timestamps()
  end

  @type t :: %__MODULE__{
    name: String.t(),
    username: String.t(),
    password: String.t(),
    email: String.t()
  }

  @type changeset :: %Ecto.Changeset{data: %__MODULE__{}}

  @spec put_password_hash(changeset) :: changeset
  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password: Argon2.hash_pwd_salt(password))
  end

  @doc false
  @spec changeset(%__MODULE__{} | t(), map()) :: changeset
  def changeset(user, attrs) do
    user
    |> cast(attrs, @casting_fields)
    |> validate_required(@required_fields)
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_format(:email, @email_regexp)
    |> validate_format(:name, @name_regexp)
    |> validate_format(:username, @username_regexp)
    |> put_password_hash()
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end
end
