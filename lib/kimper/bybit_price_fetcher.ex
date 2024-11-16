defmodule Kimper.BybitPriceFetcher do
   # TODO1: 20초마다 ping을 보내면 네트워크 이슈 피할 수 있다고 함 https://bybit-exchange.github.io/docs/v5/ws/connect#how-to-send-the-heartbeat-packet
   use WebSockex
   require Logger
   alias Kimper.Storage

  @url "wss://stream.bybit.com/v5/public/spot"
  @heartbeat_interval 20_000 # 20초

  def start_link(state) do
    {:ok, pid} = WebSockex.start_link(@url, __MODULE__, state)

    subscription_message = Jason.encode!(%{
      "op" => "subscribe",
      "args" => [
        "tickers.BTCUSDT"
      ]
    })

    WebSockex.send_frame(pid, {:text, subscription_message})
    {:ok, pid}
  end

  def init(state) do
    schedule_heartbeat()
    {:ok, state}
  end

  defp schedule_heartbeat do
    Process.send_after(self(), :send_heartbeat, @heartbeat_interval)
  end

  def handle_cast(:send_heartbeat, state) do
    case send_heartbeat() do
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

  defp send_heartbeat() do
    heartbeat_message = Jason.encode!(%{"op" => "ping"})
    WebSockex.send_frame(self(), {:text, heartbeat_message})
  end

  def handle_frame({:text, %{"success" => true, "ret_msg" => "pong"}}, state) do
    Logger.info("## Received pong")
    {:ok, state}
  end

  def handle_frame({:text, message}, state) do
    message_json = Jason.decode!(message)

    if Map.has_key?(message_json, "data") do
      price = message_json["data"]["lastPrice"]
      |> String.to_float()

      Storage.set_bybit_btc_usdt_price(price)
    end

    {:ok, state}
  end

  def handle_disconnect(reason, state) do
    Logger.error("## Disconnected from WebSocket: #{inspect(reason)}")
    {:reconnect, state}
  end
end
