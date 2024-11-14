defmodule Kimper.BybitPriceFetcher do
   # TODO1: 20초마다 ping을 보내면 네트워크 이슈 피할 수 있다고 함 https://bybit-exchange.github.io/docs/v5/ws/connect#how-to-send-the-heartbeat-packet

   use WebSockex
   alias Kimper.Storage

  @url "wss://stream.bybit.com/v5/public/spot"
  @heart_beat_interval 20_000 # 20초

  def start_link(state) do
    {:ok, pid} = WebSockex.start_link(@url, __MODULE__, state)

    subscription_message = Jason.encode!(%{
      "op" => "subscribe",
      "args" => [
        "tickers.BTCUSDT"
      ]
    })

    WebSockex.send_frame(pid, {:text, subscription_message})
    # TODO3: Process.send_after(self(), :ping, @heart_beat_interval) -> [error] Supervisor received unexpected message: :ping

    {:ok, pid}
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

  def handle_info(:ping, pid) do
    IO.inspect(pid, label: "## ping")
    heart_beat_message = Jason.encode!(%{"op" => "ping"})
    WebSockex.send_frame(pid, {:text, heart_beat_message})
    Process.send_after(self(), :ping, @heart_beat_interval)
    {:ok, pid}
  end
end
