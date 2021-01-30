defmodule CarrierPigeonWeb.ChatRoomChannel do
  use CarrierPigeonWeb, :channel
  alias Phoenix.Socket, as: Socket
  alias CarrierPigeon.Rooms, as: Rooms

  @spec can_join?(String.t(), map(), Socket.t()) :: boolean()
  defp can_join?(room_id, _payload, socket) when is_binary(room_id) do
    Rooms.is_user_in_room?(room_id, socket.assigns[:user_id])
  end

  @type topic :: String.t()
  @type channel_name :: <<_::64, _::_*8>>

  @impl true
  @spec join(channel_name, map(), Phoenix.Socket.t()) ::
    {:ok, Phoenix.Socket.t()}
    | {:error, %{reason: binary()}}
  def join("chat_room:" <> room_id, _, socket) when is_binary(room_id) do
    with \
      %{ user_id: user_id } <- socket.assigns,
      true <- can_join?(room_id, user_id, socket),
      { :ok, data } <- Room.get(room_id) do
        # Broadcast room information to the User
        push(socket, "bootstrap", data)
        assign(socket, :room_id, room_id)
        broadcast socket, "joined_to_chat", data
        { :ok, socket }
    else
      false -> { :error, %{ reason: "unauthorized" } }
      { :error, _ } -> { :error, %{ reason: "internal" } }
      _ -> { :error, %{ reason: "internal" } }
    end
  end

  @impl true
  def handle_in("ping", _payload, socket) do
    {:reply, {:ok, %{ msg: "pong" }}, socket}
  end

  @impl true
  def handle_in("send_msg", %{content: content}, socket) do
    %{ user_id: user_id, room_id: room_id } = socket.assigns

    { :ok, msg } = Rooms.insert_message(room_id, content, user_id)

    broadcast socket, "receive_msg", msg
    { :reply, :ok, socket }
  end
end
