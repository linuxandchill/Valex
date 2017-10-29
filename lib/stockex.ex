defmodule Stockex do
  @base_url Utils.return_base()
  @headers Utils.return_headers()

  def getPrices(ticker) when is_binary(ticker) do

    ticker = String.upcase(ticker)
    %HTTPoison.Response{body: info} = HTTPoison.get! @base_url <> "prices?ticker=#{ticker}", @headers
    Poison.decode! info
  end

  def eps(ticker) do 
    %HTTPoison.Response{body: resp} = HTTPoison.get! "https://api.intrinio.com/" <> "data_point?identifier=#{ticker}&item=basiceps", @headers
    resp |> Poison.decode! |> Map.get("value")
  end



end
