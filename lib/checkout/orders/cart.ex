defmodule Checkout.Orders.Cart do
  use Ecto.Schema
  import Ecto.Changeset

  schema "carts" do
    field :items, :map, default: %{}

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cart, attrs) do
    cart
    |> cast(attrs, [:items])
    |> validate_required([])
  end
end
