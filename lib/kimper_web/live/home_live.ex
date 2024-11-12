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
    upbit_krw_price = Map.get(storage, :upbit_btc_usdt_price)
    bybit_usdt_price = Map.get(storage, :bybit_btc_usdt_price)
    exchange_rate = Map.get(storage, :exchange_rate)
    bybit_krw_price = get_krw_price(bybit_usdt_price, exchange_rate)
    kimp = get_kimp(upbit_krw_price, bybit_krw_price)

    upbit_krw_price = to_str(upbit_krw_price)
    bybit_krw_price = to_str(bybit_krw_price)
    # TODO: kimp = to_str(kimp)
    # TODO: 김프 데이터에 맞게 별도 함수로 뺴기
    kimp = if is_float(upbit_krw_price) && is_float(bybit_krw_price) do
      "#{(upbit_krw_price / bybit_krw_price * 100) |> Float.round(2)}%"
    else
      "..."
    end

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

  # TODO: 각 유형에 맞게
  defp to_str(usdt_price) do
    if is_float(usdt_price), do: "#{round(usdt_price) |> Delimit.number_to_delimited()} USDT", else: "..."
  end

  # TODO: 타입체크
  defp get_krw_price(bybit_usdt_price, exchange_rate) do
    # TODO: if is_float(bybit_usdt_price) * is
    bybit_usdt_price * exchange_rate
  end

  defp get_kimp(upbit_krw_price, bybit_krw_price) do
    # TODO: 타입 체크
    bybit_krw_price
  end
end
