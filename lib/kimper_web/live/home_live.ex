defmodule KimperWeb.HomeLive do
  use KimperWeb, :live_view
  alias Kimper.Storage
  alias Number.Delimit

  @update_interval 1_000 # 1초
  @coin_tickers [:btc, :sol, :xrp, :eos, :btg]

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :update, 0)
    end

    socket = socket
    |> assign(coins: [])

    {:ok, socket, layout: false}
  end

  def handle_info(:update, socket) do
    coins = @coin_tickers
    |> Enum.map(&to_coin/1)
    |> Enum.reject(&is_nil/1)

    schedule_update()

    {:noreply, socket |> assign(coins: coins)}
  end

  defp to_coin(:btc) do
    storage = Storage.state
    upbit_krw_price = Map.get(storage, :upbit_btc_krw_price)
    bybit_usdt_price = Map.get(storage, :bybit_btc_usdt_price)
    exchange_rate = Map.get(storage, :exchange_rate)
    bybit_krw_price = get_krw_price(bybit_usdt_price, exchange_rate)
    kimp = get_kimp(upbit_krw_price, bybit_krw_price)

    upbit_krw_price = to_str_price(upbit_krw_price)
    bybit_krw_price = to_str_price(bybit_krw_price)
    kimp = to_str_kimp(kimp)

    %{
      ticker_english: "BTC",
      ticker_korean: "비트코인",
      upbit_krw_price: upbit_krw_price,
      bybit_krw_price: bybit_krw_price,
      kimp: kimp,
      telegram_link: "https://t.me/+jUKF4BTqgQNhOGY1",
    }
  end
  defp to_coin(:sol) do
    storage = Storage.state
    upbit_krw_price = Map.get(storage, :upbit_sol_krw_price)
    bybit_usdt_price = Map.get(storage, :bybit_sol_usdt_price)
    exchange_rate = Map.get(storage, :exchange_rate)
    bybit_krw_price = get_krw_price(bybit_usdt_price, exchange_rate)
    kimp = get_kimp(upbit_krw_price, bybit_krw_price)

    upbit_krw_price = to_str_price(upbit_krw_price)
    bybit_krw_price = to_str_price(bybit_krw_price)
    kimp = to_str_kimp(kimp)

    %{
      ticker_english: "SOL",
      ticker_korean: "솔라나",
      upbit_krw_price: upbit_krw_price,
      bybit_krw_price: bybit_krw_price,
      kimp: kimp,
      # TODO: 텔레그램 링크 필요
      telegram_link: ""
    }
  end
  defp to_coin(:xrp) do
    storage = Storage.state
    upbit_krw_price = Map.get(storage, :upbit_xrp_krw_price)
    bybit_usdt_price = Map.get(storage, :bybit_xrp_usdt_price)
    exchange_rate = Map.get(storage, :exchange_rate)
    bybit_krw_price = get_krw_price(bybit_usdt_price, exchange_rate)
    kimp = get_kimp(upbit_krw_price, bybit_krw_price)

    upbit_krw_price = to_str_price(upbit_krw_price)
    bybit_krw_price = to_str_price(bybit_krw_price)
    kimp = to_str_kimp(kimp)

    %{
      ticker_english: "XRP",
      ticker_korean: "리플",
      upbit_krw_price: upbit_krw_price,
      bybit_krw_price: bybit_krw_price,
      kimp: kimp,
      # TODO: 텔레그램 링크 필요
      telegram_link: ""
    }
  end
  defp to_coin(:eos) do
    storage = Storage.state
    upbit_krw_price = Map.get(storage, :upbit_eos_krw_price)
    bybit_usdt_price = Map.get(storage, :bybit_eos_usdt_price)
    exchange_rate = Map.get(storage, :exchange_rate)
    bybit_krw_price = get_krw_price(bybit_usdt_price, exchange_rate)
    kimp = get_kimp(upbit_krw_price, bybit_krw_price)

    upbit_krw_price = to_str_price(upbit_krw_price)
    bybit_krw_price = to_str_price(bybit_krw_price)
    kimp = to_str_kimp(kimp)

    %{
      ticker_english: "EOS",
      ticker_korean: "이오스",
      upbit_krw_price: upbit_krw_price,
      bybit_krw_price: bybit_krw_price,
      kimp: kimp,
      # TODO: 텔레그램 링크 필요
      telegram_link: ""
    }
  end
  defp to_coin(:btg) do
    storage = Storage.state
    upbit_krw_price = Map.get(storage, :upbit_btg_krw_price)
    bybit_usdt_price = Map.get(storage, :bybit_btg_usdt_price)
    exchange_rate = Map.get(storage, :exchange_rate)
    bybit_krw_price = get_krw_price(bybit_usdt_price, exchange_rate)
    kimp = get_kimp(upbit_krw_price, bybit_krw_price)

    upbit_krw_price = to_str_price(upbit_krw_price)
    bybit_krw_price = to_str_price(bybit_krw_price)
    kimp = to_str_kimp(kimp)

    %{
      ticker_english: "BTG",
      ticker_korean: "비트코인골드",
      upbit_krw_price: upbit_krw_price,
      bybit_krw_price: bybit_krw_price,
      kimp: kimp,
      # TODO: 텔레그램 링크 필요
      telegram_link: ""
    }
  end
  # TODO: ETH 추가 https://t.me/+Pgjk1X2adfQ0MGFl
  defp to_coin(_), do: nil

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
