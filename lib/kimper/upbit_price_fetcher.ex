defmodule Kimper.UpbitPriceFetcher do
  use WebSockex
  alias Kimper.Storage

  @url "wss://api.upbit.com/websocket/v1"
  @btc "KRW-BTC"
  @sol "KRW-SOL"
  @xrp "KRW-XRP"
  @eos "KRW-EOS"
  @btg "KRW-BTG"

  def start_link(state) do
    {:ok, pid} = WebSockex.start_link(@url, __MODULE__, state)

    subscription_message = Jason.encode!([
      %{"ticket" => "kimper"},
      %{"type" => "ticker", "codes" => [@btc, @sol, @xrp, @eos, @btg]},
    ])

    WebSockex.send_frame(pid, {:text, subscription_message})

    {:ok, pid}
  end

  def handle_frame({_type, message}, state) do
    message_json = Jason.decode!(message)
    code = message_json["code"]
    price = message_json["trade_price"]

    case code do
      @btc -> Storage.set_upbit_btc_krw_price(price)
      @sol -> Storage.set_upbit_sol_krw_price(price)
      @xrp -> Storage.set_upbit_xrp_krw_price(price)
      @eos -> Storage.set_upbit_eos_krw_price(price)
      @btg -> Storage.set_upbit_btg_krw_price(price)
      _    -> nil
    end

    {:ok, state}
  end
end
