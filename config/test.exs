import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ais_explorer, AisExplorer.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "ais_explorer_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ais_explorer, AisExplorerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "NQ9sOy3ovIH4dWvwDPsnZNxz01UL3Xh9pX2q8NiRT5hXUV4x9lvH7K8tIG4Tk2zq",
  server: false

# Configure the AIS receiver
#
# The `udp_port` is the port to listen for incoming messages
config :ais_explorer, AisExplorer.Ais.Receiver, udp_port: 123_46

# In test we don't send emails.
config :ais_explorer, AisExplorer.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
