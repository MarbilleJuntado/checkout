defmodule CheckoutWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :checkout

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_checkout_key",
    signing_salt: "2DHBShGv",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :checkout,
    gzip: false,
    only: CheckoutWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :checkout
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  # https://github.com/ajvondrak/remote_ip
  plug RemoteIp
  plug :rate_limit
  plug CheckoutWeb.Router

  defp rate_limit(conn, _opts) do
    case CheckoutWeb.RateLimit.hit(
           {:global, conn.remote_ip},
           _scale = :timer.seconds(10),
           _limit = 10
         ) do
      {:allow, _count} ->
        conn

      # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Retry-After
      {:deny, retry_after_ms} ->
        retry_after_seconds = div(retry_after_ms, 1000)

        conn
        |> put_resp_header("retry-after", "#{retry_after_seconds}")
        |> send_resp(429, "You hit the rate limit. Try again in #{retry_after_seconds} seconds.")
        |> halt()
    end
  end
end
