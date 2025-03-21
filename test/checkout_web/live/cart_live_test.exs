defmodule CheckoutWeb.CartLiveTest do
  use CheckoutWeb.ConnCase

  import Phoenix.LiveViewTest
  import Checkout.OrdersFixtures

  defp create_cart(_) do
    cart = cart_fixture()
    %{cart: cart}
  end

  describe "Index" do
    setup [:create_cart]

    test "lists all carts", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/carts")

      assert html =~ "Listing Carts"
    end

    test "saves new cart", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/carts")

      assert index_live |> element("a", "New Cart") |> render_click() =~
               "New Cart"

      assert_patch(index_live, ~p"/carts/new")

      assert index_live
             |> element("#add-CF1")
             |> render_click()

      assert index_live
             |> element("#save-btn")
             |> render_click()

      assert_patch(index_live, ~p"/carts")

      html = render(index_live)
      assert html =~ "Cart created successfully"
    end

    test "updates cart in listing", %{conn: conn, cart: cart} do
      {:ok, index_live, _html} = live(conn, ~p"/carts")

      assert index_live |> element("#carts-#{cart.id} a", "Edit") |> render_click() =~
               "Cart ID"

      assert_patch(index_live, ~p"/carts/#{cart}/edit")

      assert index_live
             |> element("#add-CF1")
             |> render_click()

      assert index_live
             |> element("#save-btn")
             |> render_click()

      assert_patch(index_live, ~p"/carts")

      html = render(index_live)
      assert html =~ "Cart updated successfully"
    end

    test "deletes cart in listing", %{conn: conn, cart: cart} do
      {:ok, index_live, _html} = live(conn, ~p"/carts")

      assert index_live |> element("#carts-#{cart.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#carts-#{cart.id}")
    end
  end

  describe "Show" do
    setup [:create_cart]

    test "displays cart", %{conn: conn, cart: cart} do
      {:ok, _show_live, html} = live(conn, ~p"/carts/#{cart}")

      assert html =~ "This is a cart record from your database."
    end

    test "updates cart within modal", %{conn: conn, cart: cart} do
      {:ok, show_live, _html} = live(conn, ~p"/carts/#{cart}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Cart ID"

      assert_patch(show_live, ~p"/carts/#{cart}/show/edit")

      assert show_live
             |> element("#add-CF1")
             |> render_click()

      assert show_live
             |> element("#save-btn")
             |> render_click()

      assert_patch(show_live, ~p"/carts/#{cart}")

      html = render(show_live)
      assert html =~ "Cart updated successfully"
    end
  end
end
