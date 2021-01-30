defmodule CarrierPigeon.Rooms do
  alias CarrierPigeon.Repo, as: Repo
  alias CarrierPigeon.Rooms.Room, as: Room
  alias Room.Query, as: RoomQuery
  alias CarrierPigeon.Rooms.Message, as: Message

  @spec get_room(String.t()) ::
    { :ok, Room.t() }
    | { :error, %{ reason: String.t() } }
  def get_room(room_id) do
    room =
      %Room{}
      |> Repo.get(room_id)
      |> Ecto.assoc(:messages)
      |> Ecto.assoc(:members)
      |> Repo.one

    if room do
      { :ok, room }
    else
      { :error, :room_not_found }
    end
  end

  @spec get_room!(String.t()) :: Room.t()
  def get_room!(room_id) do
    %Room{}
    |> Repo.get(room_id)
    |> Ecto.assoc(:messages)
    |> Ecto.assoc(:members)
    |> Repo.one
  end

  @type create_room_params :: Room.creation_params
  @spec create_room(create_room_params) ::
    { :ok, Room.t() }
    | { :error, %{ reason: String.t() }}
  def create_room(attrs) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert
  end

  @spec is_user_in_room?(String.t(), String.t()) :: any()
  def is_user_in_room?(room_id, user_id) do
    room_id
    |> RoomQuery.is_user_in_room?(user_id)
    |> Repo.one
  end

  @spec insert_message(String.t(), String.t(), String.t()) ::
    { :ok, Message.t() }
    | { :error, %{ reason: String.t() } }
  def insert_message(room_id, content, sender_id) do
    attrs = %{
      room_id: room_id,
      content: content,
      sender_id: sender_id,
    }

    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert
  end
end
