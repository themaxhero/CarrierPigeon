defmodule CarrierPigeon.Rooms do
  alias CarrierPigeon.Repo, as: Repo
  alias CarrierPigeon.Profiles.Profile, as: Profile
  alias CarrierPigeon.Rooms.Room, as: Room
  alias CarrierPigeon.Rooms.Message, as: Message
  alias Functional.Result

  @spec list_rooms(String.t()) :: [Room.t()]
  def list_rooms(profile_id) do
    { :ok, dumped_id } = Ecto.UUID.dump(profile_id)

    dumped_id
    |> Room.Query.all_rooms_for
    |> Repo.all
    |> Enum.map(&preload_room/1)
  end

  defp preload_room(%Room{} = room) do
    room
    |> Repo.preload(:messages)
    |> Repo.preload(:members)
    |> Repo.preload(:owner)
  end

  defp preload_message(%Message{} = msg) do
    msg
    |> Repo.preload(:room)
    |> Repo.preload(:sender)
  end

  @spec get_room(String.t()) ::
    { :ok, Room.t() }
    | { :error, %{ reason: String.t() } }
  def get_room(room_id) when is_binary(room_id) do
    room = Repo.get(Room, room_id)
    if room,
      do: { :ok, preload_room(room) },
      else: { :error, :room_not_found }
  end

  @spec get_room!(String.t()) :: Room.t()
  def get_room!(room_id) do
    Room
    |> Repo.get!(room_id)
    |> preload_room
  end

  @type create_room_params :: Room.creation_params
  @spec create_room_helper(Profile.t(), [Profile.t()], create_room_params) :: Room.changeset
  defp create_room_helper(%Profile{} = profile, members, attrs) when is_list(members) do
    attrs
    |> Room.changeset
    |> Ecto.Changeset.put_assoc(:members, members)
    |> Ecto.Changeset.put_assoc(:owner, profile)
    |> Ecto.Changeset.put_assoc(:messages, [])
  end

  @spec create_room(Profile.t(), [Profile.t()], create_room_params) ::
    { :ok, Room.t() }
    | { :error, %{ reason: String.t() }}
  def create_room(%Profile{} = profile, members, attrs) when is_list(members) do
    profile
    |> create_room_helper(members, attrs)
    |> Repo.insert
    |> Result.map(&preload_room/1)
  end

  @spec create_room!(Profile.t(), [Profile.t()], create_room_params) :: Room.t()
  def create_room!(%Profile{} = profile, members, attrs) when is_list(members) do
    profile
    |> create_room_helper(members, attrs)
    |> Repo.insert!
    |> preload_room
  end

  @type update_room_params :: Room.creation_params
  @spec update_room(String.t(), update_room_params) ::
    { :ok, Room.t() }
    | { :error, %{ reason: String.t() }}
  def update_room(room_id, attrs) do
    Room
    |> Repo.get(room_id)
    |> preload_room
    |> Room.changeset(attrs)
    |> Repo.update
  end

  @spec update_room!(String.t(), update_room_params) :: Room.t()
  def update_room!(room_id, attrs) do
    Room
    |> Repo.get(room_id)
    |> preload_room
    |> Room.changeset(attrs)
    |> Repo.update!
  end

  @spec delete_room(String.t() | Room.t()) ::
    { :ok, Room.t() }
    | { :error, atom() }
  def delete_room(%Room{} = room),
    do: Repo.delete(room)
  def delete_room(room_id) when is_binary(room_id) do
    room_id
    |> get_room!
    |> delete_room
  end

  @spec delete_room!(String.t() | Room.t()) :: Room.t()
  def delete_room!(%Room{} = room),
    do: Repo.delete!(room)
  def delete_room!(room_id) when is_binary(room_id) do
    room_id
    |> get_room!
    |> delete_room!
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
    |> Result.map(&preload_message/1)
  end
end
