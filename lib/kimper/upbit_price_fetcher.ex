defmodule Kimper.UpbitPriceFetcher do
  use WebSockex
  alias Kimper.Storage

  @url "wss://api.upbit.com/websocket/v1"

  def start_link(state) do
    {:ok, pid} = WebSockex.start_link(@url, __MODULE__, state)

    subscription_message = Jason.encode!([
      %{"ticket" => "kimper_test"},
      %{"type" => "ticker", "codes" => ["KRW-BTC"]},
    ])

    WebSockex.send_frame(pid, {:text, subscription_message})

    {:ok, pid}
  end

  def handle_frame({_type, message}, state) do
    price = Jason.decode!(message)["trade_price"]
    Storage.set_upbit_btc_krw_price(price)
    {:ok, state}
  end
end
