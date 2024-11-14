import Dotenvy

defmodule Kimper.FundingRateNotifier do
  @bybit_funding_rate_url "https://api-testnet.bybit.com/v5/market/funding/history?category=linear&symbol=BTCUSDT&limit=1"
  @telegram_chat_id "-1002363514381"

  # TODO2: 스케줄에 의해 텔레그램 메시지 보내기 실행 안 하는 문제
  def notify_funding_rate do
    case fetch_funding_rate() do
      {:ok, funding_rate} ->
        bot_token = env!("TELEGRAM_BOT_TOKEN", :string)
        telegram_url = "https://api.telegram.org/bot#{bot_token}/sendMessage"
        headers = [{"Content-Type", "application/json"}]
        message = "Bybit BTC/USDT 펀딩비는 #{funding_rate * 100}% 입니다."
        body = Jason.encode!(%{
          chat_id: @telegram_chat_id,
          text: message
        })

        case HTTPoison.post(telegram_url, body, headers) do
          {:error, reason} ->
            IO.puts("Failed to send telegram message: #{reason}")
        end

      {:error, reason} ->
        IO.puts("Failed to fetch funding rate: #{reason}")
    end
  end

  defp fetch_funding_rate do
    case HTTPoison.get(@bybit_funding_rate_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Jason.decode!()
        |> extract_funding_rate()

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Failed to fetch funding rate: #{reason}")
        {:error, reason}
    end
  end

  defp extract_funding_rate(%{"result" => [%{"fundingRate" => funding_rate}]}) do
    {:ok, funding_rate}
  end
  defp extract_funding_rate(_), do: {:error, "No funding rate found"}
end
