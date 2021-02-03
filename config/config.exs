# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :carrier_pigeon,
  ecto_repos: [CarrierPigeon.Repo]

# Configures the endpoint
config :carrier_pigeon, CarrierPigeonWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "My6Po0wL0CKU25aKsWyJcIlr8MkImGfgzr3u2ZotV+Zzh9MN0h3+tO9JBV7s8SKU",
  render_errors: [view: CarrierPigeonWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: CarrierPigeon.PubSub,
  live_view: [signing_salt: "2tK3WdTg"]


config :carrier_pigeon, CarrierPigeon.Guardian,
  issuer: "carrier_pigeon",
  secret_key: "My6Po0wL0CKU25aKsWyJcIlr8MkImGfgzr3u2ZotV"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
