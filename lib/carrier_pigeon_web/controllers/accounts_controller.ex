defmodule CarrierPigeonWeb.Controllers.AccountsController do
  use CarrierPigeonWeb, :controller

  alias CarrierPigeonWeb.ControllerUtils, as: Utils
  alias CarrierPigeon.Accounts, as: Accounts

  @type login_payload :: %{
    login: String.t(),
    password: String.t(),
  }

  @spec login(Plug.Conn.t(), login_payload) :: Plug.Conn.t()
  def login(conn, %{login: login, password: password}) do
    { :ok, token } = Accounts.authenticate_user(login, password)

    Utils.reply_ok(conn, %{token: token})
  end


  @type register_payload :: %{
    name: String.t(),
    email: String.t(),
    password: String.t(),
    password_confirmation: String.t(),
    username: String.t(),
  }

  @spec register(Plug.Conn.t(), register_payload) :: Plug.Conn.t()
  def register(conn, %{name: name, email: email, password: password, password_confirmation: password_confirmation, username: username}) do
    payload = %{
      name: name,
      email: email,
      password: password,
      password_confirmation: password_confirmation,
      username: username,
    }

    { :ok, user } = Accounts.create_user(payload)

    Utils.reply_ok(conn, user)
  end
  def register(conn, _),
   do: Utils.bad_request(conn)
end
