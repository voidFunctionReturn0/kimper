defmodule Kimper.Storage do
  use GenServer

  @initial_state %{}

  def start_link(_) do
    GenServer.start_link(__MODULE__, @initial_state, name: __MODULE__)
  end

  def set_upbit_btc_krw_price(price), do: GenServer.cast(__MODULE__, {:upbit_btc_krw_price, price})
  def set_upbit_xrp_krw_price(price), do: GenServer.cast(__MODULE__, {:upbit_xrp_krw_price, price})
  def set_bybit_btc_usdt_price(price), do: GenServer.cast(__MODULE__, {:bybit_btc_usdt_price, price})
  def set_exchange_rate(rate), do: GenServer.cast(__MODULE__, {:exchange_rate, rate})

  def state, do: GenServer.call(__MODULE__, :state)

  def init(state), do: {:ok, state}

  def handle_cast({:upbit_btc_krw_price, price}, state) do
    {:noreply, Map.put(state, :upbit_btc_krw_price, price)}
  end

  def handle_cast({:upbit_xrp_krw_price, price}, state) do
    {:noreply, Map.put(state, :upbit_xrp_krw_price, price)}
  end

  def handle_cast({:bybit_btc_usdt_price, price}, state) do
    {:noreply, Map.put(state, :bybit_btc_usdt_price, price)}
  end

  def handle_cast({:exchange_rate, rate}, state) do
    {:noreply, Map.put(state, :exchange_rate, rate)}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end
end
