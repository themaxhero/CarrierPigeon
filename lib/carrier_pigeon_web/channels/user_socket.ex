defmodule CarrierPigeonWeb.UserSocket do
  use Phoenix.Socket

  alias CarrierPigeon.Guardian
  alias CarrierPigeonWeb.{GuardianSerializer}

  ## Channels
  # channel "room:*", CarrierPigeonWeb.RoomChannel
  channel "account:*", CarrierPigeonWeb.AccountChannel
  channel "chat_room:*", CarrierPigeonWeb.ChatRoomChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.

  @impl true
  def connect(%{ token: token }, socket) do
    with \
      { :ok, claims } <- Guardian.decode_and_verify(token),
      { :ok, user } <- GuardianSerializer.from_token(claims["sub"]),
      socket <- assign(socket, :user_id, user.user_id)
    do
      {:ok, socket}
    else
      {:error, _reason} ->
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     CarrierPigeonWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(socket), do: "user_socket:#{socket.assigns[:user_id]}"
end
