defmodule Info do
  #import Utils
  @base_url Utils.return_base()
  @headers Utils.return_headers()
  @ticker Utils.load_ticker()

  def last_price() do 
     %HTTPoison.Response{body: resp} = 
       HTTPoison.get! @base_url <> 
       "data_point?identifier=#{@ticker}&item=last_price", 
       @headers

    last_price = 
      resp |> Utils.process_resp |> Map.get("value") 

    last_price
  end

  #net income / shares outstanding
  def eps() do 
     %HTTPoison.Response{body: net_income} = 
       HTTPoison.get! "https://api.intrinio.com/" <> "data_point?identifier=#{@ticker}&item=netincome", @headers
       net_income = net_income |> Utils.process_resp |> Map.get("value") 
%HTTPoison.Response{body: shares_os} = 
        HTTPoison.get! "https://api.intrinio.com/" <> "data_point?identifier=#{@ticker}&item=weightedavedilutedsharesos", @headers
      shares_os = shares_os |> Poison.decode! |> Map.get("value") 
      
      net_income / shares_os |> Float.round(2)
  end

  #share price / eps
   def pe do 
    share_price = last_price()
    eps = eps()
    
    share_price / eps |> Float.round(2)
   end

  #eps/share_price x 100
  def basic_expected_return() do 
   eps = eps()
   share_price = last_price()
   return = (eps / share_price)*100
   return = Float.round(return, 3) 
    |> to_string()
    return <> "%"
  end

  #curr_ass / curr_liabs
  #how will company handle debts in 
  #next 12 months
  def current_ratio do 
    %HTTPoison.Response{body: resp} = 
      HTTPoison.get! @base_url <> "data_point?identifier=#{@ticker}&item=currentratio", @headers 
      curr_ratio = resp |> Poison.decode! |> Map.get("value") |> Float.round(2)

    cond do
      curr_ratio < 1.5 -> "Less than 1.5 HIGH-RISK"
      curr_ratio >= 1.5 -> "#{curr_ratio} ACCEPTABLE" 
      true -> curr_ratio
    end
  end

  #liabs / eq
  def debt_equity do 
    %HTTPoison.Response{body: resp} = 
      HTTPoison.get! @base_url <> "data_point?identifier=AAPL&item=debttoequity", @headers
      debt_eq = resp |> Poison.decode! |> Map.get("value") |> Float.round(2)
    cond do
      debt_eq <= 0.5 -> "#{debt_eq} ACCEPTABLE"
      debt_eq > 0.5 -> "#{debt_eq} HIGH-RISK" 
      true -> debt_eq
    end
  end

  def avg_dividend do 
    %HTTPoison.Response{body: resp} = 
      HTTPoison.get! @base_url <> 
      "historical_data?identifier=DIS&item=dividend", @headers

    resp 
      |> Utils.process_resp 
      |> Map.get("data") 
      |> Stream.take(10)
      |> Enum.map(fn(x) -> Map.get(x, "value") end)
      |> Utils.average
      |> Float.round(2)
  end

  def call_ticker do 
    IO.puts @ticker
  end

end
