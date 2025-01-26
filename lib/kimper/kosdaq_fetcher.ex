defmodule Kimper.KosdaqFetcher do
  use GenServer
  alias Kimper.Storage
  alias Kimper.Indicator

  @interval 1_000 # TODO: 60초로 수정
  @initial_state %{kosdaq: nil}
  @url "https://query1.finance.yahoo.com/v8/finance/chart/^KQ11"

  def start_link(_) do
    GenServer.start_link(__MODULE__, @initial_state, name: __MODULE__)
  end

  def init(state) do
    schedule_fetch_kosdaq()
    {:ok, state}
  end

  def schedule_fetch_kosdaq, do: Process.send_after(self(), :fetch_kosdaq, @interval)

  def handle_info(:fetch_kosdaq, state) do
    new_kosdaq = fetch_kosdaq()
    Storage.set_kosdaq(new_kosdaq)
    schedule_fetch_kosdaq()
    {:noreply, %{state | kosdaq: new_kosdaq}}
  end

  # TODO: regularMarketPrice이 실시간인지 확인해보기
  defp fetch_kosdaq() do
    response = HTTPoison.get!(@url).body |> Jason.decode!()
    %{"chart" => %{"result" => [%{"meta" => %{"regularMarketPrice" => recent_value, "previousClose" => previous_close}}]}} = response
    %Indicator{recent_value: recent_value, previous_close: previous_close}
  end
end
