defmodule Ratios do 
  @base_url Utils.return_base()
  @headers Utils.return_headers()

  #net income / shares outstanding
  def eps() do 
     ticker = IO.gets "Enter symbol: "
     ticker = ticker
     |> String.upcase
     |> String.trim
     %HTTPoison.Response{body: net_income} = 
       HTTPoison.get! "https://api.intrinio.com/" <> "data_point?identifier=#{ticker}&item=netincome", @headers
       net_income = net_income |> Poison.decode! |> Map.get("value") |> round

      %HTTPoison.Response{body: shares_os} = 
        HTTPoison.get! "https://api.intrinio.com/" <> "data_point?identifier=#{ticker}&item=weightedavedilutedsharesos", @headers
      shares_os = shares_os |> Poison.decode! |> Map.get("value") |> round
      
      net_income / shares_os |> Float.round(2)
  end

  #price / eps
  #  def pe do 
  #    %HTTPoison.Response{body: price} = 
  #      HTTPoison.get! "https://api.intrinio.com/" <> "data_point?identifier=AAPL&item=last_price", @headers
  #    price = price |> Poison.decode! |> Map.get("value")  
  #
  #    price / eps() |> Float.round(2)
  #    
  #  end
  #
  def current_ratio do 
    #curr_ass / curr_liabs
  end

  def debt_equity do 
    #liabs / eq
  end
end
