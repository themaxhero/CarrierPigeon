defmodule CarrierPigeonWeb.Controllers.AccountsController do
  use CarrierPigeonWeb, :controller

  alias CarrierPigeonWeb.ControllerUtils, as: Utils
  alias CarrierPigeon.Accounts, as: Accounts

  @type register_payload :: %{
    name: String.t(),
    email: String.t(),
    password: String.t(),
    password_confirmation: String.t(),
    username: String.t(),
  }

  @spec register(Plug.Conn.t(), register_payload) :: Plug.Conn.t()
  def register(conn, %{name: _name, email: _email, password: _password, password_confirmation: _password_confirmation, username: _username} = payload) do
    { :ok, user } =
      payload
      |> Accounts.create_user

    Utils.reply_ok(conn, user)
  end
  def register(conn, _) do
    Utils.bad_request(conn)
  end
end
