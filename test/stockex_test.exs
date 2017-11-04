defmodule StockexTest do
  use ExUnit.Case
  doctest Stockex
  @base_url Utils.return_base()
  @headers Utils.return_headers()
  @ticker Utils.load_ticker()

  test "greets the world" do
    assert Stockex.hello() == :world
  end

  test "last_price() == API last_price" do 
    assert Info.last_price() == 
     %HTTPoison.Response{body: resp} = 
       HTTPoison.get! @base_url <> 
       "data_point?identifier=#{@ticker}&item=last_price", 
       @headers
        |> Utils.process_resp |> Map.get("value") 

  end
end
