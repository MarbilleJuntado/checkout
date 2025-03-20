defmodule Checkout.Repo do
  use Ecto.Repo,
    otp_app: :checkout,
    adapter: Ecto.Adapters.Postgres
end
