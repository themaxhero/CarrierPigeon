defmodule CarrierPigeonWeb.ControllerUtils do
  use CarrierPigeonWeb, :controller

  @spec reply_ok(Plug.Conn.t()) :: Plug.Conn.t()
  def reply_ok(conn) do
    put_status(conn, :ok)
  end

  @spec reply_ok(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def reply_ok(conn, data) do
    conn
    |> put_status(:ok)
    |> json(data)
  end

  @spec bad_request(Plug.Conn.t()) :: Plug.Conn.t()
  def bad_request(conn) do
    conn
    |> put_status(:bad_request)
    |> json(%{reason: "unknown_error"})
  end

  @spec bad_request(Plug.Conn.t(), binary) :: Plug.Conn.t()
  def bad_request(conn, reason) when is_binary(reason) do
    conn
    |> put_status(:bad_request)
    |> json(%{reason: reason})
  end
end
