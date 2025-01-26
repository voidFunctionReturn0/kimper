defmodule Kimper.KospiFetcher do
  use GenServer
  alias Kimper.Storage

  @interval 1_000
  @initial_state %{kospi: nil}
  @url "https://query1.finance.yahoo.com/v8/finance/chart/^KS11"

  def start_link(_) do
    GenServer.start_link(__MODULE__, @initial_state, name: __MODULE__)
  end

  def init(state) do
    schedule_fetch_kospi()
    {:ok, state}
  end

  def schedule_fetch_kospi, do: Process.send_after(self(), :fetch_kospi, @interval)

  def handle_info(:fetch_kospi, state) do
    new_kospi = fetch_kospi()
    Storage.set_kospi(new_kospi)
    schedule_fetch_kospi()
    {:noreply, %{state | kospi: new_kospi}}
  end

  # TODO: 실시간인지 확인해보기
  defp fetch_kospi() do
    response = HTTPoison.get!(@url).body |> Jason.decode!()
    %{"chart" => %{"result" => [%{"meta" => %{"regularMarketPrice" => kospi}}]}} = response
    kospi
  end
end
