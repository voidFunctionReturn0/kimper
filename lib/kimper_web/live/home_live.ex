# TODO: 모바일 뷰에서 정렬 꺠짐

defmodule KimperWeb.HomeLive do
  use KimperWeb, :live_view
  alias Kimper.Storage
  alias Number.Delimit

  @update_interval 1_000 # 1초
  @default_string "..."

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :update, 0)
    end

    socket = socket
    |> assign(coins: [])
    |> assign(kospi: %{recent_value: nil, change_amount: nil, change_rate: nil})
    |> assign(kosdaq: %{recent_value: nil, change_amount: nil, change_rate: nil})
    |> assign(update_in: @default_string)

    {:ok, socket, layout: false}
  end

  def handle_info(:update, socket) do
    coins = Storage.state.coins
    |> Enum.map(&to_coin/1)
    |> Enum.reject(&is_nil/1)

    kospi = Storage.state.kospi
    kospi_recent_value = if is_number(kospi.recent_value), do: Float.round(kospi.recent_value, 2)
    kospi_change_amount = if (is_number(kospi.recent_value) and is_number(kospi.previous_close)) do
      Float.round(kospi.recent_value - kospi.previous_close, 2)
    end
    kospi_change_rate = if (is_number(kospi.recent_value) and is_number(kospi.previous_close)) do
      Float.round((kospi.recent_value - kospi.previous_close) / kospi.previous_close * 100, 2)
    end

    kosdaq = Storage.state.kosdaq
    kosdaq_recent_value = if is_number(kosdaq.recent_value), do: Float.round(kosdaq.recent_value, 2)
    kosdaq_change_amount = if (is_number(kosdaq.recent_value) and is_number(kosdaq.previous_close)) do
      Float.round(kosdaq.recent_value - kosdaq.previous_close, 2)
    end
    kosdaq_change_rate = if (is_number(kosdaq.recent_value) and is_number(kosdaq.previous_close)) do
      Float.round((kosdaq.recent_value - kosdaq.previous_close) / kosdaq.previous_close * 100, 2)
    end

    schedule_update()

    {
      :noreply,
      socket
      |> assign(coins: coins)
      |> assign(kospi: %{
        recent_value: kospi_recent_value,
        change_amount: kospi_change_amount,
        change_rate: kospi_change_rate,
      })
      |> assign(kosdaq: %{
        recent_value: kosdaq_recent_value,
        change_amount: kosdaq_change_amount,
        change_rate: kosdaq_change_rate,
      })
      |> assign(update_in: update_in(Timex.now()))
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
      telegram_link: "https://t.me/+nF6o_U4jPyZlNjFl",
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
      telegram_link: "https://t.me/+9zYVkg6z48hhMTZl",
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
      telegram_link: "https://t.me/+-aGzpJz2als5Njk1",
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

  defp render_indicator(assigns, indicator_name, recent_value, change_amount, change_rate) do
    assigns = assigns
    |> assign(indicator_name: indicator_name)
    |> assign(recent_value: recent_value)
    |> assign(change_amount: change_amount)
    |> assign(change_rate: change_rate)

    ~H"""
      <div class="border rounded-2xl border-my_gray-7 flex flex-col gap-2 px-4 py-5">
        <div class="gap-1 text-my_black-2">
            <div class="text-body1">
                <%= @indicator_name %>
            </div>
            <div class="text-body-bold1">
                <%= @recent_value %>
            </div>
        </div>
        <div class="text-body1 flex gap-2">
            <div>
                <span class={
                    cond do
                        @change_amount > 0 -> "text-my_red-3"
                        @change_amount < 0 -> "text-my_blue-2"
                    end
                }>
                    <%!-- TODO: 화살표를 디자인 파일에 있는 것처럼 수정 필요 --%>
                    <%= cond do %>
                        <% @change_amount > 0 -> %>
                            ▲
                        <% @change_amount < 0 -> %>
                            ▼
                    <% end %>
                    <%= @change_amount %>
                </span>
            </div>
            <div>
                <span class={
                    cond do
                        @change_rate > 0 -> "text-my_red-3"
                        @change_rate < 0 -> "text-my_blue-2"
                    end
                }>
                  <%= cond do %>
                    <% @change_rate > 0 -> %>
                        +<%= @change_rate %>%
                    <% @change_rate < 0 -> %>
                        -<%= @change_rate %>%
                  <% end %>
                </span>
            </div>
        </div>
      </div>
    """
  end
end
