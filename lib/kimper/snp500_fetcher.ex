defmodule Kimper.Snp500Fetcher do
  use GenServer
  alias Kimper.Storage
  alias Kimper.Indicator

  @interval 60_000
  @initial_state %{snp500: nil}
  @url "https://query1.finance.yahoo.com/v8/finance/chart/^GSPC"

  def start_link(_) do
    GenServer.start_link(__MODULE__, @initial_state, name: __MODULE__)
  end

  def init(state) do
    Process.send_after(self(), :fetch_snp500, 0)
    schedule_fetch_snp500()
    {:ok, state}
  end

  def schedule_fetch_snp500, do: Process.send_after(self(), :fetch_snp500, @interval)

  def handle_info(:fetch_snp500, state) do
    new_snp500 = fetch_snp500()
    Storage.set_snp500(new_snp500)
    schedule_fetch_snp500()
    {:noreply, %{state | snp500: new_snp500}}
  end

  def fetch_snp500() do
    response = HTTPoison.get!(@url).body |> Jason.decode!()
    %{"chart" => %{"result" => [%{"meta" => %{"regularMarketPrice" => recent_value, "previousClose" => previous_close}}]}} = response
    %Indicator{recent_value: recent_value, previous_close: previous_close}
  end
end
