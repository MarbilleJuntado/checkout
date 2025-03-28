defmodule CheckoutWeb.RateLimit do
  @moduledoc """
  Thin wrapper around `:ets.update_counter/4` and a clean-up process to act as a fixed window rate limiter.

  Based on https://github.com/michalmuskala/plug_attack
  """

  use GenServer
  @table __MODULE__

  @doc """
  Starts the process that creates and cleans the ETS table.

  Accepts the following options:
  - `:clean_period` for how often to perform garbage collection, defaults to 10 minutes
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @doc "Increments count and checks if it's still within limit"
  def hit(key, scale, limit, increment \\ 1) do
    now = now()
    window = div(now, scale)
    full_key = {key, window}
    expires_at = (window + 1) * scale
    count = :ets.update_counter(@table, full_key, increment, {full_key, 0, expires_at})
    if count <= limit, do: {:allow, count}, else: {:deny, _retry_after = expires_at - now}
  end

  @impl true
  def init(opts) do
    clean_period = Keyword.get(opts, :clean_period, :timer.minutes(10))

    :ets.new(@table, [
      :named_table,
      :set,
      :public,
      {:read_concurrency, true},
      {:write_concurrency, true},
      {:decentralized_counters, true}
    ])

    schedule(clean_period)
    {:ok, %{clean_period: clean_period}}
  end

  @impl true
  def handle_info(:clean, state) do
    :ets.select_delete(@table, [{{{:_, :_}, :_, :"$1"}, [], [{:<, :"$1", {:const, now()}}]}])
    schedule(state.clean_period)
    {:noreply, state}
  end

  defp schedule(clean_period) do
    Process.send_after(self(), :clean, clean_period)
  end

  @compile inline: [now: 0]
  defp now do
    System.system_time(:millisecond)
  end
end
