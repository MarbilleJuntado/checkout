defmodule Checkout.Repo.Migrations.CreateCarts do
  use Ecto.Migration

  def change do
    create table(:carts) do
      add :items, :map

      timestamps(type: :utc_datetime)
    end
  end
end
