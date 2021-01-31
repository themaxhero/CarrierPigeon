defmodule CarrierPigeon.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset

  alias CarrierPigeon.Accounts.User, as: User
  alias CarrierPigeon.Profiles.Profile, as: Profile
  alias CarrierPigeon.Rooms.Message, as: Message

  @primary_key { :room_id, :binary_id, autogenerate: true }

  @uuid_regexp ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

  @type t :: %__MODULE__{
    name: String.t() | nil,
    type: :pm | :group,
    members: [Profile.t()],
    owner: User.t(),
  }

  @casting_fields [:name, :type, :member_ids, :owner_id ]
  @required_fields [:name, :type, :member_ids ]

  schema "rooms" do
    field :name, :string
    field :type, Ecto.Enum, values: [:pm, :group]

    has_many :members, Profile,
      foreign_key: :profile_id

    belongs_to :owner, Profile,
      foreign_key: :profile_id,
      references: :profile_id,
      type: :binary_id

    has_many :messages, Message,
      foreign_key: :msg_id,
      on_delete: :delete_all

    timestamps()
  end

  @type changeset :: %Ecto.Changeset{
    data: %__MODULE__{},
  }

  @type creation_attrs :: %{
    optional(:name) => String.t(),
    optional(:owner_id) => String.t(),
    type: :pm | :group,
    member_ids: [String.t()],
  }

  def validate_members(changeset, field) do
    validate_change(
      changeset,
      field,
      fn (_, value) ->
        Enum.all?(value, &(String.match?(&1, @uuid_regexp)))
      end
    )
  end

  @spec changeset(%__MODULE__{} | changeset, creation_attrs) :: changeset
  def changeset(room \\ %__MODULE__{}, attrs) do
    room
    |> cast(attrs, @casting_fields)
    |> validate_required(@required_fields)
    |> validate_format(:owner_id, @uuid_regexp)
    |> validate_members(:member_ids)
    |> cast_assoc(:members)
    |> cast_assoc(:owner)
    |> cast_assoc(:messages)
  end

  defmodule Query do
    import Ecto.Query

    alias Ecto.Queryable
    alias CarrierPigeon.Rooms.Room

    @spec is_user_in_room?(String.t(), String.t()) :: Queryable.t()
    def is_user_in_room?(room_id, profile_id),
      do: from rm in "room_members",
        where: rm.room_id == ^room_id and rm.profile_id == ^profile_id,
        select: count(rm) > 0

    @spec all_rooms_for(String.t()) :: Queryable.t()
    def all_rooms_for(profile_id) do
      from rm in "room_members",
        join: r in Room, on: r.room_id == rm.room_id,
        where: rm.profile_id == ^profile_id,
        select: r
    end
  end
end
