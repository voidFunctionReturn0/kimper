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
    |> assign(upbit_krw_price: nil)
    |> assign(bybit_krw_price: nil)
    |> assign(kimp: nil)

    {:ok, socket, layout: false}
  end

  def handle_info(:update, socket) do
    storage = Storage.state
    upbit_krw_price = Map.get(storage, :upbit_btc_krw_price)
    bybit_usdt_price = Map.get(storage, :bybit_btc_usdt_price)
    exchange_rate = Map.get(storage, :exchange_rate)
    bybit_krw_price = get_krw_price(bybit_usdt_price, exchange_rate)
    kimp = get_kimp(upbit_krw_price, bybit_krw_price)

    upbit_krw_price = to_str_price(upbit_krw_price)
    bybit_krw_price = to_str_price(bybit_krw_price)
    kimp = to_str_kimp(kimp)

    schedule_update()

    socket = socket
    |> assign(upbit_krw_price: upbit_krw_price)
    |> assign(bybit_krw_price: bybit_krw_price)
    |> assign(kimp: kimp)

    {:noreply, socket}
  end

  defp schedule_update() do
    Process.send_after(self(), :update, @update_interval)
  end

  defp get_krw_price(bybit_usdt_price, exchange_rate) when is_float(bybit_usdt_price) and is_float(exchange_rate) do
    bybit_usdt_price * exchange_rate
  end
  defp get_krw_price(_, _), do: nil

  defp get_kimp(upbit_krw_price, bybit_krw_price) when is_float(upbit_krw_price) and is_float(bybit_krw_price) do
    (upbit_krw_price / bybit_krw_price - 1) * 100
  end
  defp get_kimp(_, _), do: nil

  defp to_str_price(krw_price) when is_float(krw_price) do
    "#{round(krw_price) |> Delimit.number_to_delimited(precision: 0)}원"
  end
  defp to_str_price(_), do: "..."

  defp to_str_kimp(kimp) when is_float(kimp) do
    "#{Float.round(kimp, 2)}%"
  end
  defp to_str_kimp(_), do: "..."
end
