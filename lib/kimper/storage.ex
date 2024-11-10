defmodule Kimper.Storage do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def set_upbit_btc_usdt_price(price), do: GenServer.cast(__MODULE__, {:upbit_btc_usdt_price, price})
  def set_bybit_btc_usdt_price(price), do: GenServer.cast(__MODULE__, {:bybit_btc_usdt_price, price})

  def prices, do: GenServer.call(__MODULE__, :prices)

  def init(state), do: {:ok, state}

  def handle_cast({:upbit_btc_usdt_price, price}, state) do
    {:noreply, Map.put(state, :upbit_btc_usdt_price, price)}
  end

  def handle_cast({:bybit_btc_usdt_price, price}, state) do
    {:noreply, Map.put(state, :bybit_btc_usdt_price, price)}
  end

  def handle_call(:prices, _from, state) do
    {:reply, state, state}
  end
end
