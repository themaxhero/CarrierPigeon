defmodule CarrierPigeon.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset

  alias CarrierPigeon.Accounts.User, as: User
  alias CarrierPigeon.Profiles.Profile, as: Profile

  @primary_key { :room_id, :binary_id, autogenerate: true }

  @uuid_regexp ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

  @type t :: %__MODULE__{
    name: String.t() | nil,
    type: :pm | :group,
    members: [Profile.t()],
    owner: User.t(),
  }

  @casting_fields ~w(name type member_ids owner_id)
  @required_fields ~w(name type member_ids owner_id)

  schema "rooms" do
    field :name, :string
    field :type, Ecto.Enum, values: [:pm, :group]

    has_many :members, Profile,
      foreign_key: :profile_id

    belongs_to :owner, User,
      foreign_key: :user_id,
      references: :user_id,
      type: :binary_id

    timestamps()
  end

  @type changeset :: %Ecto.Changeset{
    data: %__MODULE__{},
  }

  @type creation_attrs :: %{
    optional(:name) => String.t(),
    type: atom(),
    member_ids: [String.t()],
    owner_id: String.t()
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
  def changeset(user, attrs) do
    user
    |> cast(attrs, @casting_fields)
    |> validate_required(@required_fields)
    |> validate_format(:owner_id, @uuid_regexp)
    |> validate_members(:member_ids)
  end

  defmodule Query do
    import Ecto.Query

    alias Ecto.Queryable
    alias CarrierPigeon.Accounts.User, as: User
    alias CarrierPigeon.Rooms.Room, as: Room

    @spec is_user_in_room?(binary(), binary()) :: Queryable.t()
    def is_user_in_room?(room_id, profile_id) do
      from p in Room,
        join: c in assoc(p, :members),
        where: c.profile_id == ^profile_id,
        limit: 1,
        select: c
    end
  end
end
