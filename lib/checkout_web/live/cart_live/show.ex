defmodule CheckoutWeb.CartLive.Show do
  use CheckoutWeb, :live_view

  alias Checkout.Orders

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    cart = Orders.get_cart!(id)
    total = Orders.total(cart)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:cart, cart)
     |> assign(:total, total)}
  end

  defp page_title(:show), do: "Show Cart"
  defp page_title(:edit), do: "Edit Cart"
end
