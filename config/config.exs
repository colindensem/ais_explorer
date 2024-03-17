# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ais_explorer,
  ecto_repos: [AisExplorer.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configure the UDP server
#
# The `file_path` is the path to the file containing the sentences to transmit
# The `broadcast_ip` and `broadcast_port` are the IP and port to broadcast to
# The `transmit_delay` is the delay before sending any messages in microseconds
# The `max_transmit_rate` is the rate/limit at which to transmit messages per second
config :ais_explorer, AisExplorer.Ais.Server,
  file_path: "priv/data/marine_cadastre_extract.csv",
  broadcast_ip: {127, 0, 0, 1},
  broadcast_port: 12345,
  transmit_delay: 10_000,
  max_transmit_rate: 5_000

# Configure the AIS receiver
#
# The `udp_port` is the port to listen for incoming messages
config :ais_explorer, AisExplorer.Ais.Receiver, udp_port: 12345

# Configure the NMEA writer
#
# The `flush_interval_ms` is the interval at which to flush the buffer
# The `max_buffer_size` is the maximum number of events to buffer before flushing
config :ais_explorer, AisExplorer.Nmea.Writer,
  flush_interval_ms: 5_000,
  max_buffer_size: 3_000

# Configures the endpoint
config :ais_explorer, AisExplorerWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: AisExplorerWeb.ErrorHTML, json: AisExplorerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: AisExplorer.PubSub,
  live_view: [signing_salt: "d3fQiV4g"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :ais_explorer, AisExplorer.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  ais_explorer: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  ais_explorer: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
