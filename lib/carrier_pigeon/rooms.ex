defmodule CarrierPigeon.Rooms do
  alias CarrierPigeon.Repo, as: Repo
  alias CarrierPigeon.Rooms.Room, as: Room
  alias CarrierPigeon.Rooms.Message, as: Message

  @spec get(String.t()) ::
    { :ok, Room.t() }
    | { :error, %{ reason: String.t() } }
  def get(room_id) do
    %Room{}
    |> Repo.get(room_id)
  end

  @spec create_room(Room.creation_params) ::
    { :ok, Room.t() }
    | { :error, %{ reason: String.t() }}
  def create_room(attrs) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert
  end

  @spec is_user_in_room?(String.t(), String.t()) :: boolean()
  def is_user_in_room?(room_id, user_id) do
    room_id
    |> Room.Query.create(user_id)
    |> Repo.query
    |> Enum.empty?
    |> Kernel.!
  end

  @spec insert_message(String.t(), String.t(), String.t()) ::
    { :ok, Message.t() }
    | { :error, %{reason: String.t()} }
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
