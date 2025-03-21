defmodule CheckoutWeb.PageController do
  use CheckoutWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: "/carts")
  end
end
