# TODO: 모바일 뷰에서 정렬 꺠짐

defmodule KimperWeb.HomeLive do
  use KimperWeb, :live_view
  alias Kimper.Storage
  alias Number.Delimit

  @update_interval 1_000 # 1초

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :update, 0)
    end

    # TODO: exchange_rate는 임시로 추가함. 나중에 제거해야 함. 환율이 매일 업데이트되는지 확인해보고. 1/19 기준 1456.10781342임
    socket = socket
    |> assign(coins: [])
    |> assign(update_in: "...")
    |> assign(exchange_rate: "...")

    {:ok, socket, layout: false}
  end

  def handle_info(:update, socket) do
    coins = Storage.state.coins
    |> Enum.map(&to_coin/1)
    |> Enum.reject(&is_nil/1)

    schedule_update()

    # TODO: exchange_rate는 임시로 추가함. 나중에 제거해야 함. 환율이 매일 업데이트되는지 확인해보고. 1/19 기준 1456.10781342임
    {
      :noreply,
      socket
      |> assign(coins: coins)
      |> assign(update_in: update_in(Timex.now()))
      |> assign(exchange_rate: Storage.state.exchange_rate)
    }
  end

  defp to_coin(:btc) do
    storage = Storage.state
    upbit_krw_price = get_in(storage, [:btc, :upbit, :krw])
    bybit_krw_price = get_in(storage, [:btc, :bybit, :usdt_to_krw])
    kimp = get_in(storage, [:btc, :kimp])
    bybit_usd_funding_rate = get_in(storage, [:btc, :bybit, :usd_funding_rate])

    upbit_krw_price = to_str_price(upbit_krw_price)
    bybit_krw_price = to_str_price(bybit_krw_price)
    kimp = to_str_kimp(kimp)
    bybit_usd_funding_rate = to_str_funding_rate(bybit_usd_funding_rate)

    %{
      ticker_english: "BTC",
      ticker_korean: "비트코인",
      upbit_krw_price: upbit_krw_price,
      bybit_krw_price: bybit_krw_price,
      kimp: kimp,
      telegram_link: "https://t.me/+jUKF4BTqgQNhOGY1",
      bybit_usd_funding_rate: bybit_usd_funding_rate,
    }
  end
  defp to_coin(:sol) do
    storage = Storage.state
    upbit_krw_price = get_in(storage, [:sol, :upbit, :krw])
    bybit_krw_price = get_in(storage, [:sol, :bybit, :usdt_to_krw])
    kimp = get_in(storage, [:sol, :kimp])
    bybit_usd_funding_rate = get_in(storage, [:btc, :bybit, :usd_funding_rate])

    upbit_krw_price = to_str_price(upbit_krw_price)
    bybit_krw_price = to_str_price(bybit_krw_price)
    kimp = to_str_kimp(kimp)
    bybit_usd_funding_rate = to_str_funding_rate(bybit_usd_funding_rate)

    %{
      ticker_english: "SOL",
      ticker_korean: "솔라나",
      upbit_krw_price: upbit_krw_price,
      bybit_krw_price: bybit_krw_price,
      kimp: kimp,
      # TODO: 텔레그램 링크 필요
      telegram_link: "",
      bybit_usd_funding_rate: bybit_usd_funding_rate,
    }
  end
  defp to_coin(:xrp) do
    storage = Storage.state
    upbit_krw_price = get_in(storage, [:xrp, :upbit, :krw])
    bybit_krw_price = get_in(storage, [:xrp, :bybit, :usdt_to_krw])
    kimp = get_in(storage, [:xrp, :kimp])
    bybit_usd_funding_rate = get_in(storage, [:btc, :bybit, :usd_funding_rate])

    upbit_krw_price = to_str_price(upbit_krw_price)
    bybit_krw_price = to_str_price(bybit_krw_price)
    kimp = to_str_kimp(kimp)
    bybit_usd_funding_rate = to_str_funding_rate(bybit_usd_funding_rate)

    %{
      ticker_english: "XRP",
      ticker_korean: "리플",
      upbit_krw_price: upbit_krw_price,
      bybit_krw_price: bybit_krw_price,
      kimp: kimp,
      # TODO: 텔레그램 링크 필요
      telegram_link: "",
      bybit_usd_funding_rate: bybit_usd_funding_rate,
    }
  end
  defp to_coin(:eos) do
    storage = Storage.state
    upbit_krw_price = get_in(storage, [:eos, :upbit, :krw])
    bybit_krw_price = get_in(storage, [:eos, :bybit, :usdt_to_krw])
    kimp = get_in(storage, [:eos, :kimp])
    bybit_usd_funding_rate = get_in(storage, [:btc, :bybit, :usd_funding_rate])

    upbit_krw_price = to_str_price(upbit_krw_price)
    bybit_krw_price = to_str_price(bybit_krw_price)
    kimp = to_str_kimp(kimp)
    bybit_usd_funding_rate = to_str_funding_rate(bybit_usd_funding_rate)

    %{
      ticker_english: "EOS",
      ticker_korean: "이오스",
      upbit_krw_price: upbit_krw_price,
      bybit_krw_price: bybit_krw_price,
      kimp: kimp,
      # TODO: 텔레그램 링크 필요
      telegram_link: "",
      bybit_usd_funding_rate: bybit_usd_funding_rate,
    }
  end
  defp to_coin(:eth) do
    storage = Storage.state
    upbit_krw_price = get_in(storage, [:eth, :upbit, :krw])
    bybit_krw_price = get_in(storage, [:eth, :bybit, :usdt_to_krw])
    kimp = get_in(storage, [:eth, :kimp])
    bybit_usd_funding_rate = get_in(storage, [:btc, :bybit, :usd_funding_rate])

    upbit_krw_price = to_str_price(upbit_krw_price)
    bybit_krw_price = to_str_price(bybit_krw_price)
    kimp = to_str_kimp(kimp)
    bybit_usd_funding_rate = to_str_funding_rate(bybit_usd_funding_rate)

    %{
      ticker_english: "ETH",
      ticker_korean: "이더리움",
      upbit_krw_price: upbit_krw_price,
      bybit_krw_price: bybit_krw_price,
      kimp: kimp,
      telegram_link: "https://t.me/+Pgjk1X2adfQ0MGFl",
      bybit_usd_funding_rate: bybit_usd_funding_rate,
    }
  end
  defp to_coin(_), do: nil

  defp schedule_update() do
    Process.send_after(self(), :update, @update_interval)
  end

  defp to_str_price(krw_price) when is_float(krw_price) do
    "#{round(krw_price) |> Delimit.number_to_delimited(precision: 0)}원"
  end
  defp to_str_price(_), do: "..."

  defp to_str_kimp(kimp) when is_float(kimp) do
    "#{Float.round(kimp, 2)}%"
  end
  defp to_str_kimp(_), do: "..."

  defp to_str_funding_rate(funding_rate) when is_float(funding_rate) do
    "#{Float.round(funding_rate * 100, 2)}%"
  end
  defp to_str_funding_rate(_), do: "..."

  defp update_in(utc_current_time) do
    current_hour = utc_current_time.hour
    next_update_hour = cond do
      current_hour in 0..7    -> 8
      current_hour in 8..15   -> 16
      current_hour in 16..23  -> 24
    end
    left_hour = next_update_hour - current_hour - 1
    left_minute = 59 - utc_current_time.minute
    left_second = 59 - utc_current_time.second

    [left_hour, left_minute, left_second] = [left_hour, left_minute, left_second]
    |> Enum.map(&format_to_double_zero/1)

    "#{left_hour}:#{left_minute}:#{left_second}"
  end

  defp format_to_double_zero(number) when is_integer(number) do
    number
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end
end
