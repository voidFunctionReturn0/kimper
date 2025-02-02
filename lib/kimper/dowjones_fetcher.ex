defmodule Kimper.DowjonesFetcher do
  use GenServer
  alias Kimper.Storage
  alias Kimper.Indicator

  @interval 60_000
  @initial_state %{dowjones: nil}
  @url "https://query1.finance.yahoo.com/v8/finance/chart/^DJI"

  def start_link(_) do
    GenServer.start_link(__MODULE__, @initial_state, name: __MODULE__)
  end

  def init(state) do
    Process.send_after(self(), :fetch_dowjones, 0)
    schedule_fetch_dowjones()
    {:ok, state}
  end

  def schedule_fetch_dowjones, do: Process.send_after(self(), :fetch_dowjones, @interval)

  def handle_info(:fetch_dowjones, state) do
    new_dowjones = fetch_dowjones()
    Storage.set_dowjones(new_dowjones)
    schedule_fetch_dowjones()
    {:noreply, %{state | dowjones: new_dowjones}}
  end

  def fetch_dowjones() do
    response = HTTPoison.get!(@url).body |> Jason.decode!()
    %{"chart" => %{"result" => [%{"meta" => %{"regularMarketPrice" => recent_value, "previousClose" => previous_close}}]}} = response
    %Indicator{recent_value: recent_value, previous_close: previous_close}
  end
end
