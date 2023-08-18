import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :open_graph_previewer, OpenGraphPreviewer.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "open_graph_previewer_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :open_graph_previewer, OpenGraphPreviewerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "zaeZfj7KKbIfYpixdlG3Ry01+6FNPQJUn2VWVZpNE86G6fbIWnv3lCFd0Bqu6paq",
  server: false

# In test we don't send emails.
config :open_graph_previewer, OpenGraphPreviewer.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
