defmodule CarrierPigeonWeb.AccountChannel do
  use CarrierPigeonWeb, :channel

  alias CarrierPigeon.Accounts
  alias CarrierPigeon.Profiles
  alias CarrierPigeon.Rooms

  # Helpers
  @spec create_and_broadcast_room(Profiles.Profile.t(), [Profiles.Profile.t()], Rooms.create_room_params, Phoenix.Socket.t()) :: any()
  defp create_and_broadcast_room(profile, members, payload, socket) do
    case Rooms.create_room(profile, members, payload) do
      { :ok, room } ->
        push socket, "room_creation_success", room
        broadcast socket, "included_in_room", room
      { :error, reason } ->
        push socket, "room_creation_failed", %{ reason: reason }
    end
  end

  @spec create_and_send_profile(Accounts.User.t(), Profiles.create_profile_params, Phoenix.Socket.t()) :: any()
  defp create_and_send_profile(user, payload, socket) do
    case Profiles.create_profile(user, payload) do
      { :ok, profile } ->
        push socket, "profile_creation_successful", profile

      { :error, _reason } ->
        push socket, "profile_creation_failed", %{ reason: "profile_creation_failed" }
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
    user = Accounts.get_user!(socket.assigns[:user_id])
    payload = %{
      nickname: nickname,
      avatar: avatar,
      owner: user,
    }

    create_and_send_profile(user, payload, socket)

    { :noreply, socket }
  end
  def handle_in("create.room", %{ type: :pm, pair: pair_id }, socket) when is_binary(pair_id) do
    profile_id = socket.assigns[:profile_id]

    { :ok, profile_user } = Profiles.get_profile(profile_id)
    { :ok, profile_pair } = Profiles.get_profile(pair_id)

    members = [ profile_user, profile_pair ]

    payload = %{
      type: :pm
    }

    create_and_broadcast_room(profile_user, members, payload, socket)

    { :noreply, socket }
  end
  def handle_in(
    "create.room",
    %{ type: :group, name: name, member_ids: member_ids},
    %Phoenix.Socket{ assigns: %{ profile_id: profile_id, joined: true } } = socket
  )
    when is_binary(name)
    and is_binary(profile_id)
    and is_list(member_ids)
  do
    member_ids = List.insert_at(member_ids, 0, profile_id)
    members = Enum.map(member_ids, &Profiles.get_profile!/1)
    profile = Profiles.get_profile!(profile_id)

    payload = %{
      type: :group,
      name: name,
      owner: profile,
      members: members,
    }

    create_and_broadcast_room(profile, members, payload, socket)

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
