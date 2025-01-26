defmodule Kimper.Storage do
  use GenServer
  alias Kimper.Indicator

  @initial_state %{
    coins: [:btc, :sol, :xrp, :eos, :eth],
    btc: %{upbit: %{krw: nil}, bybit: %{usdt: nil, usdt_to_krw: nil, usd_funding_rate: nil}, kimp: nil},
    sol: %{upbit: %{krw: nil}, bybit: %{usdt: nil, usdt_to_krw: nil, usd_funding_rate: nil}, kimp: nil},
    xrp: %{upbit: %{krw: nil}, bybit: %{usdt: nil, usdt_to_krw: nil, usd_funding_rate: nil}, kimp: nil},
    eos: %{upbit: %{krw: nil}, bybit: %{usdt: nil, usdt_to_krw: nil, usd_funding_rate: nil}, kimp: nil},
    eth: %{upbit: %{krw: nil}, bybit: %{usdt: nil, usdt_to_krw: nil, usd_funding_rate: nil}, kimp: nil},
    exchange_rate: nil,
    kospi: %Indicator{},
    kosdaq: %Indicator{},
  }

  def start_link(_), do: GenServer.start_link(__MODULE__, @initial_state, name: __MODULE__)

  def set_upbit_krw_price(price, :btc), do: GenServer.cast(__MODULE__, {:upbit_krw_price, price, :btc})
  def set_upbit_krw_price(price, :sol), do: GenServer.cast(__MODULE__, {:upbit_krw_price, price, :sol})
  def set_upbit_krw_price(price, :xrp), do: GenServer.cast(__MODULE__, {:upbit_krw_price, price, :xrp})
  def set_upbit_krw_price(price, :eos), do: GenServer.cast(__MODULE__, {:upbit_krw_price, price, :eos})
  def set_upbit_krw_price(price, :eth), do: GenServer.cast(__MODULE__, {:upbit_krw_price, price, :eth})

  def set_bybit_usdt_price(price, :btc), do: GenServer.cast(__MODULE__, {:bybit_usdt_price, price, :btc})
  def set_bybit_usdt_price(price, :sol), do: GenServer.cast(__MODULE__, {:bybit_usdt_price, price, :sol})
  def set_bybit_usdt_price(price, :xrp), do: GenServer.cast(__MODULE__, {:bybit_usdt_price, price, :xrp})
  def set_bybit_usdt_price(price, :eos), do: GenServer.cast(__MODULE__, {:bybit_usdt_price, price, :eos})
  def set_bybit_usdt_price(price, :eth), do: GenServer.cast(__MODULE__, {:bybit_usdt_price, price, :eth})

  def set_bybit_usd_funding_rate(rate, :btc), do: GenServer.cast(__MODULE__, {:bybit_usd_funding_rate, rate, :btc})
  def set_bybit_usd_funding_rate(rate, :sol), do: GenServer.cast(__MODULE__, {:bybit_usd_funding_rate, rate, :sol})
  def set_bybit_usd_funding_rate(rate, :xrp), do: GenServer.cast(__MODULE__, {:bybit_usd_funding_rate, rate, :xrp})
  def set_bybit_usd_funding_rate(rate, :eos), do: GenServer.cast(__MODULE__, {:bybit_usd_funding_rate, rate, :eos})
  def set_bybit_usd_funding_rate(rate, :eth), do: GenServer.cast(__MODULE__, {:bybit_usd_funding_rate, rate, :eth})

  def set_exchange_rate(rate), do: GenServer.cast(__MODULE__, {:exchange_rate, rate})
  def set_kospi(kospi), do: GenServer.cast(__MODULE__, {:kospi, kospi})
  def set_kosdaq(kosdaq), do: GenServer.cast(__MODULE__, {:kosdaq, kosdaq})

  def state, do: GenServer.call(__MODULE__, :state)

  def init(state), do: {:ok, state}

  def handle_cast({:upbit_krw_price, price, :btc}, state), do: {:noreply, put_in(state, [:btc, :upbit, :krw], price)}
  def handle_cast({:upbit_krw_price, price, :sol}, state), do: {:noreply, put_in(state, [:sol, :upbit, :krw], price)}
  def handle_cast({:upbit_krw_price, price, :xrp}, state), do: {:noreply, put_in(state, [:xrp, :upbit, :krw], price)}
  def handle_cast({:upbit_krw_price, price, :eos}, state), do: {:noreply, put_in(state, [:eos, :upbit, :krw], price)}
  def handle_cast({:upbit_krw_price, price, :eth}, state), do: {:noreply, put_in(state, [:eth, :upbit, :krw], price)}

  def handle_cast({:bybit_usdt_price, price, :btc}, state), do: {:noreply, put_in(state, [:btc, :bybit, :usdt], price)}
  def handle_cast({:bybit_usdt_price, price, :sol}, state), do: {:noreply, put_in(state, [:sol, :bybit, :usdt], price)}
  def handle_cast({:bybit_usdt_price, price, :xrp}, state), do: {:noreply, put_in(state, [:xrp, :bybit, :usdt], price)}
  def handle_cast({:bybit_usdt_price, price, :eos}, state), do: {:noreply, put_in(state, [:eos, :bybit, :usdt], price)}
  def handle_cast({:bybit_usdt_price, price, :eth}, state), do: {:noreply, put_in(state, [:eth, :bybit, :usdt], price)}

  def handle_cast({:bybit_usd_funding_rate, rate, :btc}, state), do: {:noreply, put_in(state, [:btc, :bybit, :usd_funding_rate], rate)}
  def handle_cast({:bybit_usd_funding_rate, rate, :sol}, state), do: {:noreply, put_in(state, [:sol, :bybit, :usd_funding_rate], rate)}
  def handle_cast({:bybit_usd_funding_rate, rate, :xrp}, state), do: {:noreply, put_in(state, [:xrp, :bybit, :usd_funding_rate], rate)}
  def handle_cast({:bybit_usd_funding_rate, rate, :eos}, state), do: {:noreply, put_in(state, [:eos, :bybit, :usd_funding_rate], rate)}
  def handle_cast({:bybit_usd_funding_rate, rate, :eth}, state), do: {:noreply, put_in(state, [:eth, :bybit, :usd_funding_rate], rate)}

  def handle_cast({:exchange_rate, rate}, state), do: {:noreply, Map.put(state, :exchange_rate, rate)}
  def handle_cast({:kospi, kospi}, state), do: {:noreply, Map.put(state, :kospi, kospi)}
  def handle_cast({:kosdaq, kosdaq}, state), do: {:noreply, Map.put(state, :kosdaq, kosdaq)}

  def handle_call(:state, _from, state) do
    new_state = state
    |> Enum.map(fn {key, value} ->
      if (key in state.coins) do
        bybit_usdt_price = value[:bybit][:usdt]
        exchange_rate = state[:exchange_rate]
        bybit_krw_price = get_krw_price(bybit_usdt_price, exchange_rate)
        {key, put_in(value, [:bybit, :usdt_to_krw], bybit_krw_price)}
      else
        {key, value}
      end
    end)
    |> Enum.map(fn {key, value} ->
      if (key in state.coins) do
        upbit_krw_price = value[:upbit][:krw]
        bybit_krw_price = value[:bybit][:usdt_to_krw]
        kimp = get_kimp(upbit_krw_price, bybit_krw_price)
        {key, put_in(value[:kimp], kimp)}
      else
        {key, value}
      end
    end)
    |> Map.new()

    {:reply, new_state, new_state}
  end

  defp get_krw_price(bybit_usdt_price, exchange_rate) when is_float(bybit_usdt_price) and is_float(exchange_rate) do
    bybit_usdt_price * exchange_rate
  end
  defp get_krw_price(_, _), do: nil

  defp get_kimp(upbit_krw_price, bybit_krw_price) when is_float(upbit_krw_price) and is_float(bybit_krw_price) do
    (upbit_krw_price / bybit_krw_price - 1) * 100
  end
  defp get_kimp(_, _), do: nil
end
