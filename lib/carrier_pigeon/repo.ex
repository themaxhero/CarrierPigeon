defmodule CarrierPigeon.Repo do
  use Ecto.Repo,
    otp_app: :carrier_pigeon,
    adapter: Ecto.Adapters.Postgres
end
