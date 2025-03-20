defmodule CheckoutWeb.CartLive.Index do
  use CheckoutWeb, :live_view

  alias Checkout.Orders
  alias Checkout.Orders.Cart

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :carts, Orders.list_carts())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Cart")
    |> assign(:cart, Orders.get_cart!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Cart")
    |> assign(:cart, %Cart{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Carts")
    |> assign(:cart, nil)
  end

  @impl true
  def handle_info({CheckoutWeb.CartLive.FormComponent, {:saved, cart}}, socket) do
    {:noreply, stream_insert(socket, :carts, cart)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    cart = Orders.get_cart!(id)
    {:ok, _} = Orders.delete_cart(cart)

    {:noreply, stream_delete(socket, :carts, cart)}
  end
end
