defmodule CarrierPigeon.Profiles.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  alias CarrierPigeon.Accounts.User, as: User
  alias CarrierPigeon.Rooms.Room, as: Room

  @primary_key { :profile_id, :binary_id, autogenerate: true }

  @uuid_regexp ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

  @casting_fields [:nickname, :avatar, :room_id, :sender_id]
  @required_fields [:nickname, :room_id, :sender_id]

  @type t :: %__MODULE__{
    nickname: String.t(),
    avatar: String.t() | nil,
    rooms: [Room.t()],
    owner: User.t(),
  }

  schema "profiles" do
    field :nickname, :string
    field :avatar, :string

    has_many :rooms, Room,
      foreign_key: :room_id

    belongs_to :owner, User,
      foreign_key: :owner_id,
      references: :user_id,
      type: :binary_id

    timestamps()
  end

  @type changeset :: %Ecto.Changeset{
    data: %__MODULE__{},
  }

  @type creation_attrs :: %{
    nickname: String.t(),
    avatar: String.t() | nil,
    room_ids: [String.t()],
    owner_id: String.t(),
  }

  def validate_rooms(changeset, field) do
    validate_change(
      changeset,
      field,
      fn (_, value) ->
        Enum.all?(value, &(String.match?(&1, @uuid_regexp)))
      end
    )
  end

  @spec changeset(%__MODULE__{} | changeset, creation_attrs) :: changeset
  def changeset(user, attrs) do
    user
    |> cast(attrs, @casting_fields)
    |> validate_required(@required_fields)
    |> validate_rooms(:room_ids)
    |> validate_format(:owner_id, @uuid_regexp)
  end
end
