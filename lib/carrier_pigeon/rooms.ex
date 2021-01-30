defmodule CarrierPigeon.Rooms do
  alias CarrierPigeon.Repo, as: Repo
  alias CarrierPigeon.Rooms.Room, as: Room
  alias CarrierPigeon.Rooms.Message, as: Message

  @spec list_rooms(String.t()) :: [Room.t()]
  def list_rooms(profile_id) do
    profile_id
    |> Room.Query.all_rooms_for
    |> Repo.all
  end

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

  @spec create_room!(create_room_params) :: Room.t()
  def create_room!(attrs) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert!
  end

  @type update_room_params :: Room.creation_params
  @spec update_room(String.t(), update_room_params) ::
    { :ok, Room.t() }
    | { :error, %{ reason: String.t() }}
  def update_room(room_id, attrs) do
    %Room{}
    |> Repo.get(room_id)
    |> Room.changeset(attrs)
    |> Repo.update
  end

  @spec update_room!(String.t(), update_room_params) :: Room.t()
  def update_room!(room_id, attrs) do
    %Room{}
    |> Repo.get(room_id)
    |> Room.changeset(attrs)
    |> Repo.update!
  end

  @spec is_user_in_room?(String.t(), String.t()) :: any()
  def is_user_in_room?(room_id, profile_id) do
    room_id
    |> get_room!
    |> Map.get(:members)
    |> Enum.find(&(&1.profile_id == profile_id))
    |> Kernel.!=(nil)
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
