defmodule Checkout.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Checkout.Orders` context.
  """

  @doc """
  Generate a cart.
  """
  def cart_fixture(attrs \\ %{}) do
    {:ok, cart} =
      attrs
      |> Enum.into(%{
        items: %{}
      })
      |> Checkout.Orders.create_cart()

    cart
  end
end
