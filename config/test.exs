import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :checkout, Checkout.Repo,
  url: "postgres://postgres:postgres@db/checkout_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10,
  timeout: :infinity

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :checkout, CheckoutWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "yZrJNBjwOcLlRp99jYDNY05jcuYDujAriXDMwg+ddBQLENgswOmyG3DrUIeOEt0f",
  server: false

# In test we don't send emails
config :checkout, Checkout.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
