defmodule KimperWeb.HomeLive do
  use KimperWeb, :live_view
  alias Kimper.Storage
  alias Number.Delimit

  @update_interval 1_000 # 1초

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :update, 0)
    end

    socket = socket
    |> assign(upbit_price: nil)
    |> assign(bybit_price: nil)
    |> assign(kimp: nil)

    {:ok, socket, layout: false}
  end

  def handle_info(:update, socket) do
    prices = Storage.prices
    upbit_price = Map.get(prices, :upbit_btc_usdt_price)
    bybit_price = Map.get(prices, :bybit_btc_usdt_price)

    kimp = if is_float(upbit_price) && is_float(bybit_price) do
      "#{(upbit_price / bybit_price * 100) |> Float.round(2)}%"
    else
      "..."
    end

    upbit_price = to_str(upbit_price)
    bybit_price = to_str(bybit_price)

    schedule_update()

    socket = socket
    |> assign(upbit_price: upbit_price)
    |> assign(bybit_price: bybit_price)
    |> assign(kimp: kimp)

    {:noreply, socket}
  end

  defp schedule_update() do
    Process.send_after(self(), :update, @update_interval)
  end

  defp to_str(usdt_price) do
    if is_float(usdt_price), do: "#{round(usdt_price) |> Delimit.number_to_delimited()} USDT", else: "..."
  end
end
