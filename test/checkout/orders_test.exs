defmodule Checkout.OrdersTest do
  use Checkout.DataCase

  alias Checkout.Orders

  describe "carts" do
    alias Checkout.Orders.Cart

    import Checkout.OrdersFixtures

    @invalid_attrs %{items: []}

    test "list_carts/0 returns all carts" do
      cart = cart_fixture()
      assert Orders.list_carts() == [cart]
    end

    test "get_cart!/1 returns the cart with given id" do
      cart = cart_fixture()
      assert Orders.get_cart!(cart.id) == cart
    end

    test "create_cart/1 with valid data creates a cart" do
      valid_attrs = %{items: %{"GR1" => 1}}

      assert {:ok, %Cart{} = cart} = Orders.create_cart(valid_attrs)
      assert cart.items == %{"GR1" => 1}
    end

    test "create_cart/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_cart(@invalid_attrs)
    end

    test "update_cart/2 with valid data updates the cart" do
      cart = cart_fixture()
      update_attrs = %{items: %{"GR1" => 2}}

      assert {:ok, %Cart{} = cart} = Orders.update_cart(cart, update_attrs)
      assert cart.items == %{"GR1" => 2}
    end

    test "update_cart/2 with invalid data returns error changeset" do
      cart = cart_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_cart(cart, @invalid_attrs)
      assert cart == Orders.get_cart!(cart.id)
    end

    test "delete_cart/1 deletes the cart" do
      cart = cart_fixture()
      assert {:ok, %Cart{}} = Orders.delete_cart(cart)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_cart!(cart.id) end
    end

    test "change_cart/1 returns a cart changeset" do
      cart = cart_fixture()
      assert %Ecto.Changeset{} = Orders.change_cart(cart)
    end

    test "total/1 returns a float equal total amount of cart items" do
      cart = cart_fixture()

      # test case 1
      update_attrs = %{items: %{"GR1" => 3, "SR1" => 1, "CF1" => 1}}
      assert {:ok, %Cart{} = cart} = Orders.update_cart(cart, update_attrs)
      assert 22.45 == Orders.total(cart)

      # test case 2
      update_attrs = %{items: %{"GR1" => 2}}
      assert {:ok, %Cart{} = cart} = Orders.update_cart(cart, update_attrs)
      assert 3.11 == Orders.total(cart)

      # test case 3
      update_attrs = %{items: %{"SR1" => 3, "GR1" => 1}}
      assert {:ok, %Cart{} = cart} = Orders.update_cart(cart, update_attrs)
      assert 16.61 == Orders.total(cart)

      # test case 4
      update_attrs = %{items: %{"GR1" => 1, "CF1" => 3, "SR1" => 1}}
      assert {:ok, %Cart{} = cart} = Orders.update_cart(cart, update_attrs)
      assert 30.57 == Orders.total(cart)
    end
  end
end
