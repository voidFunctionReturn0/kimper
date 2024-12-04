defmodule Kimper.FundingRateNotifier do
  @bybit_funding_rate_url "https://api.bybit-tr.com/v5/market/funding/history?category=linear&symbol=BTCUSD&limit=1"
  @telegram_chat_id "-1002363514381"

  def notify_funding_rate do
    IO.puts("## notify_funding_rate")
    case fetch_funding_rate() do
      {:ok, funding_rate} ->
        IO.puts("## fetch_funding_rate ok")
        bot_token = System.get_env("TELEGRAM_BOT_TOKEN")
        telegram_url = "https://api.telegram.org/bot#{bot_token}/sendMessage"
        headers = [{"Content-Type", "application/json"}]
        message = "Bybit BTCUSD 펀딩비는 #{String.to_float(funding_rate) * 100}% 입니다."
        body = Jason.encode!(%{
          chat_id: @telegram_chat_id,
          text: message
        })

        case HTTPoison.post(telegram_url, body, headers) do
          {:ok, _response} ->
            IO.puts("## post ok")
            nil
          {:error, reason} ->
            IO.puts("## Failed to send telegram message: #{reason}")
        end

      {:error, reason} ->
        IO.puts("## Failed to fetch funding rate in notify_funding_rate function: #{reason}")
    end
  end

  defp fetch_funding_rate do
    case HTTPoison.get(@bybit_funding_rate_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Jason.decode!()
        |> extract_funding_rate()

      {:error, message} ->
        IO.puts("## Failed to fetch funding rate: #{message}")
        {:error, message.reason}
    end
  end

  defp extract_funding_rate(%{"result" => %{"list" => [%{"fundingRate" => funding_rate}]}}) do
    {:ok, funding_rate}
  end
  defp extract_funding_rate(_), do: {:error, "## No funding rate found"}
end
