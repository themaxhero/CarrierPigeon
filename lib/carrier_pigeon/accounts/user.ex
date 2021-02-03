defmodule CarrierPigeon.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias CarrierPigeon.Profiles.Profile

  alias Argon2

  @primary_key { :user_id, :binary_id, autogenerate: true }

  @casting_fields [:name, :username, :password, :email]
  @required_fields [:name, :username, :password, :email]

  @email_regexp ~r/@/

  @name_regexp ~r/.+\s.+/

  @username_regexp ~r/^[A-Za-z0-9_\-\.]{4,32}$/

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string
    field :username, :string
    has_many :profiles, Profile,
      foreign_key: :user_id

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
    |> validate_confirmation(:password, message: "passwords does not match")
    |> validate_format(:email, @email_regexp)
    |> unique_constraint(:email)
    |> validate_format(:name, @name_regexp)
    |> validate_format(:username, @username_regexp)
    |> put_password_hash
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  defmodule Query do
    import Ecto.Query, only: [from: 2]
    alias CarrierPigeon.Accounts.User

    def query_user_by_email(login),
      do: from u in User, where: u.email == ^login
  end
end
