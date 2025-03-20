defmodule Checkout.PricingRules do
  @products %{
    "GR1" => 3.11,
    "SR1" => 5.00,
    "CF1" => 11.23
  }

  def price("GR1", count) do
    div(count, 2) * @products["GR1"] + rem(count, 2) * @products["GR1"]
  end

  def price("SR1", count) when count >= 3 do
    count * 4.50
  end

  def price("SR1", count), do: count * @products["SR1"]

  def price("CF1", count) when count >= 3 do
    count * (@products["CF1"] * 2 / 3)
  end

  def price("CF1", count), do: count * @products["CF1"]

  def price(product_code, count) do
    if price = @products[product_code] do
      count * price
    else
      0.0
    end
  end
end
