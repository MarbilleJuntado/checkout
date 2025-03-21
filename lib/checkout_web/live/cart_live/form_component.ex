defmodule CheckoutWeb.CartLive.FormComponent do
  use CheckoutWeb, :live_component

  alias Checkout.{Orders, PriceRules}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= if @cart.id do %>
        <h3 class="text-xl font-semibold">Cart ID: {@cart.id}</h3>
      <% end %>

      <h3 class="mt-4 font-semibold">Products</h3>
      <div class="flex gap-2">
        <%= for {product_code, product} <- Checkout.Utils.products() do %>
          <button
            id={"add-#{product_code}"}
            phx-click="add_item"
            phx-value-product={product_code}
            phx-target={@myself}
            class="btn"
          >
            Add {product["name"]} (£{product["price"]})
          </button>
        <% end %>
      </div>

      <div class="border-t pt-4">
        <h2 class="text-lg font-semibold">Cart</h2>
        <%= if map_size(@items) == 0 do %>
          <p class="text-gray-500 italic">Cart is empty.</p>
        <% else %>
          <ul class="list-none space-y-2">
            <%= for {product_code, qty} <- @items do %>
              <li class="flex justify-between items-center border-b pb-2">
                <span class="text-lg">
                  {get_in(Checkout.Utils.products(), [product_code, "name"])} ({product_code}) x {qty}
                </span>
                <div class="flex space-x-2">
                  <button
                    phx-click="subtract_item"
                    phx-value-product={product_code}
                    phx-target={@myself}
                    class="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600"
                  >
                    -
                  </button>
                  <button
                    phx-click="add_item"
                    phx-value-product={product_code}
                    phx-target={@myself}
                    class="bg-green-500 text-white px-3 py-1 rounded hover:bg-green-600"
                  >
                    +
                  </button>
                </div>
              </li>
            <% end %>
          </ul>
        <% end %>
      </div>

      <h3 class="total mt-4">Total: £{@total}</h3>

      <div class="flex space-x-4 mt-6">
        <%= if @items != %{} do %>
          <button
            phx-click="empty_cart"
            phx-target={@myself}
            data-confirm="Are you sure?"
            class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600"
          >
            Empty Cart
          </button>
        <% end %>
        <button
          id="save-btn"
          phx-click="save_cart"
          phx-target={@myself}
          class="px-4 py-2 bg-yellow-500 text-white rounded hover:bg-yellow-600"
        >
          Save Cart
        </button>
      </div>
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
  def handle_event("empty_cart", _params, socket) do
    assigns = %{
      items: %{},
      total: 0.0
    }

    {:noreply, assign(socket, assigns)}
  end

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
    items = Map.update(assigns.items, product, 1, &(&1 + 1))

    assigns = %{
      items: items,
      total: calculate_total(items)
    }

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("subtract_item", %{"product" => product}, %{assigns: assigns} = socket) do
    items =
      assigns.items
      |> Map.update(product, 0, &max(&1 - 1, 0))
      |> Enum.reject(fn {_k, v} -> v == 0 end)
      |> Enum.into(%{})

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
end
