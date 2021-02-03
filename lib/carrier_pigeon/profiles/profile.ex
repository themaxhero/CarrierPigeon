defmodule CarrierPigeon.Profiles.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  alias CarrierPigeon.Accounts.User, as: User
  alias CarrierPigeon.Rooms.Room, as: Room

  @primary_key { :profile_id, :binary_id, autogenerate: true }

  @uuid_regexp ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

  @casting_fields [ :nickname, :avatar ]
  @required_fields [ :nickname ]

  @type t :: %__MODULE__{
    nickname: String.t(),
    avatar: String.t() | nil,
    rooms: [Room.t()],
    user: User.t(),
  }

  schema "profiles" do
    field :nickname, :string
    field :avatar, :string,
      null: true

    many_to_many :rooms, Room,
      join_through: RoomMember,
      join_keys: [ profile_id: :profile_id, room_id: :room_id ]

    belongs_to :user, User,
      foreign_key: :user_id,
      references: :user_id,
      type: :binary_id

    timestamps()
  end

  @type changeset :: %Ecto.Changeset{
    data: %__MODULE__{},
  }

  @type creation_attrs :: %{
    optional(:avatar) => String.t(),
    nickname: String.t(),
    user: User.t(),
  }

  @type update_attrs :: %{
    optional(:avatar) => String.t(),
    optional(:nickname) => String.t(),
    optional(:user) => User.t(),
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
  def changeset(%__MODULE__{} = profile, attrs \\ %{}) do
    profile
    |> cast(attrs, @casting_fields)
    |> validate_required(@required_fields)
  end
end
