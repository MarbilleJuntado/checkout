defmodule Checkout.Utils do
  @moduledoc """
  Module with helper functions
  """

  def products,
    do: %{
      "GR1" => %{
        "name" => "Green Tea",
        "price" => "3.11"
      },
      "SR1" => %{
        "name" => "Strawberries",
        "price" => "5.00"
      },
      "CF1" => %{
        "name" => "Coffee",
        "price" => "11.23"
      }
    }
end
