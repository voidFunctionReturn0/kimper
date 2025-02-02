defmodule Kimper.NasdaqFetcher do
  use GenServer
  require Logger
  alias Kimper.Storage
  alias Kimper.Indicator

  @interval 60_000
  @initial_state %{nasdaq: nil}
  @url "https://query1.finance.yahoo.com/v8/finance/chart/^IXIC"

  def start_link(_) do
    GenServer.start_link(__MODULE__, @initial_state, name: __MODULE__)
  end

  def init(state) do
    Process.send_after(self(), :fetch_nasdaq, 0)
    schedule_fetch_nasdaq()
    {:ok, state}
  end

  def schedule_fetch_nasdaq, do: Process.send_after(self(), :fetch_nasdaq, @interval)

  def handle_info(:fetch_nasdaq, state) do
    new_nasdaq = fetch_nasdaq()
    Storage.set_nasdaq(new_nasdaq)
    schedule_fetch_nasdaq()
    {:noreply, %{state | nasdaq: new_nasdaq}}
  end

  def fetch_nasdaq() do
    response = HTTPoison.get!(@url).body |> Jason.decode!()
    %{"chart" => %{"result" => [%{"meta" => %{"regularMarketPrice" => recent_value, "previousClose" => previous_close}}]}} = response
    %Indicator{recent_value: recent_value, previous_close: previous_close}
  end
end
