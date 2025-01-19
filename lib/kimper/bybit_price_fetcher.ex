# TODO: 20초마다 하트비트 ping 보내기?

defmodule Kimper.BybitPriceFetcher do
  use WebSockex
  require Logger
  alias Kimper.Storage

  @url "wss://stream.bybit.com/v5/public/linear"
  @btc "tickers.BTCUSDT"
  @sol "tickers.SOLUSDT"
  @xrp "tickers.XRPUSDT"
  @eos "tickers.EOSUSDT"
  @eth "tickers.ETHUSDT"

  def start_link(_state) do
    case WebSockex.start_link(@url, __MODULE__, %{}, name: __MODULE__) do
      {:ok, pid} ->
        subscription_message = Jason.encode!(%{
          "op" => "subscribe",
          "args" => [@btc, @sol, @xrp, @eos, @eth]
        })
        WebSockex.send_frame(pid, {:text, subscription_message})
        {:ok, pid}

      {:error, reason} ->
        Logger.error("WebSocket 연결 실패: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def handle_frame({:text, message}, state) do
    message_json = Jason.decode!(message)

    price = message_json
    |> Map.get("data", %{})
    |> Map.get("lastPrice", nil)

    topic = message_json
    |> Map.get("topic", nil)

    if price != nil and topic != nil do
      price = String.to_float(price)

      case message_json["topic"] do
        @btc -> Storage.set_bybit_usdt_price(price, :btc)
        @sol -> Storage.set_bybit_usdt_price(price, :sol)
        @xrp -> Storage.set_bybit_usdt_price(price, :xrp)
        @eos -> Storage.set_bybit_usdt_price(price, :eos)
        @eth -> Storage.set_bybit_usdt_price(price, :eth)
        _    -> Logger.error("## unexpected bybit topic")
      end
    end

    {:ok, state}
  end

  def handle_disconnect(_reason, state) do
    Logger.error("WebSocket 연결 끊김, 다시 연결 시도 중...")
    {:reconnect, state}
  end
end
