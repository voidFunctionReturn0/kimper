# TODO: 자꾸 셧다운되는 문제 해결 필요

defmodule Kimper.BybitPriceFetcher do
   use WebSockex
   require Logger
   alias Kimper.Storage

  @url "wss://stream.bybit.com/v5/public/spot"
  @heartbeat_interval 20_000 # 20초
  @btc "tickers.BTCUSDT"
  @sol "tickers.SOLUSDT"
  @xrp "tickers.XRPUSDT"
  @eos "tickers.EOSUSDT"
  @eth "tickers.ETHUSDT"

  def start_link(state) do
    case WebSockex.start_link(@url, __MODULE__, state) do
      {:ok, pid} ->
        subscription_message = Jason.encode!(%{
          "op" => "subscribe",
          "args" => [@btc, @sol, @xrp, @eos, @eth]
        })
        WebSockex.send_frame(pid, {:text, subscription_message})
        {:ok, pid}

      {:error, reason} ->
        Logger.error("## Failed to start WebSocket: #{inspect(reason)}")
        {:error, reason}
    end
  end

  ## TODO: init 실행 안됨 -> 하트비트 실행 안됨
  def init(state) do
    schedule_heartbeat()
    {:ok, state}
  end

  defp schedule_heartbeat do
    Process.send_after(self(), :send_heartbeat, @heartbeat_interval)
  end

  def handle_cast(:send_heartbeat, state) do
    case send_heartbeat(self()) do
      :ok                -> Logger.info("## Heartbeat sent successfully")
      {:error, reason}   -> Logger.error("## Failed to send Heartbeat: #{inspect(reason)}")
    end

    schedule_heartbeat()
    {:ok, state}
  end

  def handle_cast({:error, reason}, state) do
    Logger.error("## Error in WebSocket: #{inspect(reason)}")
    {:noreply, state}
  end

  defp send_heartbeat(pid) do
    heartbeat_message = Jason.encode!(%{"op" => "ping"})
    WebSockex.send_frame(pid, {:text, heartbeat_message})
  end

  def handle_frame({:text, %{"success" => true, "ret_msg" => "pong"}}, state) do
    Logger.info("## Received pong")
    {:ok, state}
  end

  def handle_frame({:text, message}, state) do
    message_json = Jason.decode!(message)

    if Map.has_key?(message_json, "data") do
      price = message_json["data"]["lastPrice"] |> String.to_float()

      case message_json["topic"] do
        @btc -> Storage.set_bybit_usdt_price(price, :btc)
        @sol -> Storage.set_bybit_usdt_price(price, :sol)
        @xrp -> Storage.set_bybit_usdt_price(price, :xrp)
        @eos -> Storage.set_bybit_usdt_price(price, :eos)
        @eth -> Storage.set_bybit_usdt_price(price, :eth)
        _    -> IO.puts("## unexpected bybit topic")
      end
    end

    {:ok, state}
  end

  def handle_disconnect(reason, state) do
    Logger.error("## Disconnected from WebSocket: #{inspect(reason)}")
    {:reconnect, state}
  end
end
