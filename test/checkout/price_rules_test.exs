defmodule Checkout.PriceRulesTest do
  use ExUnit.Case, async: true
  alias Checkout.PriceRules

  describe "GR1 (Green Tea - buy-one-get-one-free)" do
    test "1 GR1 costs 3.11" do
      assert PriceRules.price("GR1", 1) == 3.11
    end

    test "2 GR1 cost 3.11 (BOGOF)" do
      assert PriceRules.price("GR1", 2) == 3.11
    end

    test "3 GR1 cost 6.22 (2 charged, 1 free)" do
      assert PriceRules.price("GR1", 3) == 6.22
    end

    test "4 GR1 cost 6.22" do
      assert PriceRules.price("GR1", 4) == 6.22
    end
  end

  describe "SR1 (Strawberries - price drops to 4.50 each for 3+)" do
    test "1 SR1 costs 5.00" do
      assert PriceRules.price("SR1", 1) == 5.00
    end

    test "2 SR1 cost 10.00" do
      assert PriceRules.price("SR1", 2) == 10.00
    end

    test "3 SR1 cost 13.50" do
      assert PriceRules.price("SR1", 3) == 13.50
    end

    test "5 SR1 cost 22.50" do
      assert PriceRules.price("SR1", 5) == 22.50
    end
  end

  describe "CF1 (Coffee - buy 3+, get 1/3 off each)" do
    test "1 CF1 costs 11.23" do
      assert PriceRules.price("CF1", 1) == 11.23
    end

    test "2 CF1 cost 22.46" do
      assert PriceRules.price("CF1", 2) == 22.46
    end

    test "3 CF1 cost 22.46 (3 * 11.23 * 2/3)" do
      expected = 3 * (11.23 * 2 / 3)
      assert Float.round(PriceRules.price("CF1", 3), 2) == Float.round(expected, 2)
    end

    test "4 CF1 cost 29.94" do
      expected = 4 * (11.23 * 2 / 3)
      assert Float.round(PriceRules.price("CF1", 4), 2) == Float.round(expected, 2)
    end
  end

  describe "Unknown product codes" do
    test "returns 0.0 for unknown products" do
      assert PriceRules.price("XYZ", 1) == 0.0
    end
  end
end
