defmodule CarrierPigeon.Rooms.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias CarrierPigeon.Rooms.Room, as: Room
  alias CarrierPigeon.Profiles.Profile, as: Profile

  @primary_key { :msg_id, :binary_id, autogenerate: true }

  @casting_fields [:content, :room_id, :sender_id]
  @required_fields [:content, :room_id, :sender_id]

  @uuid_regexp ~r/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i

  @type t :: %__MODULE__{
    content: String.t(),
    room: Room.t(),
    sender: Profile.t(),
  }

  schema "room_messages" do
    field :content, :string

    belongs_to :room, Room,
      foreign_key: :room_id,
      references: :room_id,
      type: :binary_id

    belongs_to :sender, Profile,
      foreign_key: :sender_id,
      references: :profile_id,
      type: :binary_id

    timestamps()
  end

  @type changeset :: %Ecto.Changeset{
    data: %__MODULE__{}
  }

  @type creation_attrs :: %{
    content: String.t(),
    room_id: String.t(),
    sender_id: String.t()
  }

  @spec changeset(%__MODULE__{} | changeset, creation_attrs) :: changeset
  def changeset(user, attrs) do
    user
    |> cast(attrs, @casting_fields)
    |> validate_required(@required_fields)
    |> validate_format(:room_id, @uuid_regexp)
    |> validate_format(:sender_id, @uuid_regexp)
  end
end
