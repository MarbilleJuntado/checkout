defmodule CheckoutWeb.CartLive.FormComponent do
  use CheckoutWeb, :live_component

  alias Checkout.{Orders, PriceRules}

  @impl true
  def render(assigns) do
    ~H"""
      <div>
        <%= if @cart.id do %>
          <h3 class="text-xl font-semibold">Cart ID: <%= @cart.id %></h3>
        <% end %>

        <h3 class="mt-4 font-semibold">Products</h3>
        <div class="flex gap-2">
          <%= for {product_code, product} <- products() do %>
            <button phx-click="add_item" phx-value-product={product_code} phx-target={@myself} class="btn">Add {product["name"]} (£{product["price"]})</button>
          <% end %>
        </div>

        <h3 class="mt-4 font-semibold">Cart Items</h3>
        <ul class="list-disc pl-5">
          <%= for {product, count} <- @items do %>
            <li><%= get_in(products(), [product, "name"]) %> (<%= product %>): <%= count %></li>
          <% end %>
        </ul>

        <h3 class="total mt-4">Total: £<%= @total %></h3>

        <%= if @items != %{} do %>
          <div class="flex space-x-4 mt-6">
            <button phx-click="empty_cart" class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600">Empty Cart</button>
            <button phx-click="save_cart" phx-target={@myself} class="px-4 py-2 bg-yellow-500 text-white rounded hover:bg-yellow-600">Save Cart</button>
          </div>
        <% end %>
      </div>
    """
  end

  @impl true
  def update(%{cart: cart} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:total, fn -> calculate_total(cart.items) end)
     |> assign_new(:items, fn -> cart.items || %{} end)}
  end

  @impl true
  def handle_event("save_cart", _params, %{assigns: %{cart: %{id: id}}} = socket) do
    cart_params = %{items: socket.assigns.items}

    action =
      if is_nil(id) do
        :new
      else
        :edit
      end

    save_cart(socket, action, cart_params)
  end

  def handle_event("add_item", %{"product" => product}, %{assigns: assigns} = socket) do
    items =  Map.update(assigns.items, product, 1, &(&1 + 1))

    assigns = %{
      items: items,
      total: calculate_total(items)
    }

    {:noreply, assign(socket, assigns)}
  end

  defp calculate_total(items) do
    items
    |> Enum.map(fn {product, count} -> PriceRules.price(product, count) end)
    |> Enum.sum()
    |> Kernel.*(1.0)
    |> Float.round(2)
  end

  defp save_cart(socket, :edit, cart_params) do
    case Orders.update_cart(socket.assigns.cart, cart_params) do
      {:ok, cart} ->
        notify_parent({:saved, cart})

        {:noreply,
         socket
         |> put_flash(:info, "Cart updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        error = "Failed to update cart: #{inspect(changeset.errors)}"

        {:noreply, put_flash(socket, :error, error)}
    end
  end

  defp save_cart(socket, :new, cart_params) do
    case Orders.create_cart(cart_params) do
      {:ok, cart} ->
        notify_parent({:saved, cart})

        {:noreply,
         socket
         |> put_flash(:info, "Cart created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp products, do: %{
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
