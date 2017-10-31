defmodule Stockex do
  @base_url Utils.return_base()
  @headers Utils.return_headers()
  #import Utils
  #import Info

  def getPrices(ticker) when is_binary(ticker) do

    ticker = String.upcase(ticker)
    %HTTPoison.Response{body: info} = HTTPoison.get! @base_url <> "prices?ticker=#{ticker}", @headers
    Poison.decode! info
  end




end
