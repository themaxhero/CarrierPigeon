defmodule CarrierPigeonWeb.AccountChannel do
  use CarrierPigeonWeb, :channel

  alias CarrierPigeon.Profiles
  alias CarrierPigeon.Rooms

  # Helpers
  @spec create_and_broadcast_room(Rooms.create_room_params, Phoenix.Socket.t()) :: any()
  defp create_and_broadcast_room(payload, socket) do
    case Rooms.create_room(payload) do
      { :ok, room } ->
        push socket, "room_creation_success", room
        broadcast socket, "included_in_room", room
      { :error, reason } ->
        push socket, "room_creation_failed", %{ reason: reason }
    end
  end

  @spec create_and_send_profile(Profiles.create_profile_params, Phoenix.Socket.t()) :: any()
  defp create_and_send_profile(payload, socket) do
    case Profiles.create_profile(payload) do
      { :ok, profile } ->
        push socket, "profile_creation_successful", profile

      { :error, reason } ->
        push socket, "profile_creation_failed", %{ reason: reason }
    end
  end

  @impl true
  @spec join(String.t(), map(), Phoenix.Socket.t()) ::
    { :ok, Phoenix.Socket.t() }
    | { :error, map() }
  def join("account:lobby", _, socket) do
    if socket.assigns[:user_id] do
      last_logged_in_profile_id = socket.assigns[:user_id]
      socket = assign(socket, :profile_id, last_logged_in_profile_id)

      { :ok, socket }
    else
      { :error, %{ reason: "user_not_found"} }
    end
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (account:lobby).
  @impl true
  @spec handle_in(String.t(), map(), Phoenix.Socket.t()) ::
    { :reply, atom() | {atom(), map()}, Phoenix.Socket.t() }
    | { :noreply, Phoenix.Socket.t() }
  def handle_in("create.profile", %{nickname: nickname, avatar: avatar}, socket) do
    payload = %{
      nickname: nickname,
      avatar: avatar,
      room_ids: [],
      owner_id: socket.assigns[:user_id],
    }

    create_and_send_profile(payload, socket)

    { :noreply, socket }
  end
  def handle_in("create.room", %{ type: :pm, pair: pair_id }, socket) when is_binary(pair_id) do
    profile_id = socket.assigns[:profile_id]
    member_ids = [ profile_id, pair_id ]
    payload = %{
      type: :pm,
      member_ids: member_ids,
    }

    create_and_broadcast_room(payload, socket)

    { :noreply, socket }
  end
  def handle_in("create.room", %{ type: :group, name: name, member_ids: member_ids}, socket)
    when is_binary(name)
    and is_list(member_ids)
  do
    profile_id = socket.assigns[:profile_id]
    payload = %{
      type: :group,
      name: name,
      owner_id: profile_id,
      member_ids: [ profile_id | member_ids],
    }

    create_and_broadcast_room(payload, socket)

    { :noreply, socket }
  end
  def handle_in("create.room", %{ type: "pm", pair: pair_id }, socket) when is_binary(pair_id),
    do: handle_in("create.room", %{ type: :pm, pair: pair_id }, socket)
  def handle_in("create.room", %{ type: "group", pair: pair_id }, socket) when is_binary(pair_id),
    do: handle_in("create.room", %{ type: :group, pair: pair_id }, socket)
  def handle_in("ping", _, socket),
    do: { :reply, { :ok, %{ msg: "pong" } }, socket }
  def handle_in(_, _, socket),
    do: { :reply, {:error, %{ reason: "bad_request" } }, socket}
end
