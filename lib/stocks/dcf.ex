defmodule DCF do 
  @base_url Utils.return_base()
  @headers Utils.return_headers()
  @ticker Utils.load_ticker()


  #final step
  #dcf yrs 1-10is + dcf yrs >11 / sharesos
  def dcf_iv(rate) do 
    dfc_short = dfcf(rate)
    dfc_long = dpcf(rate)
      
    %HTTPoison.Response{body: resp} = 
         HTTPoison.get! @base_url <> 
         "data_point?ticker=#{@ticker}"
         <> "&item=weightedavedilutedsharesos", 
         @headers

     shares_os = 
       resp 
       |> Poison.decode! 
       |> Map.get("value") 
       |> round

      sum = (dfc_short + dfc_long) |> round
      sum / shares_os
  end

  def rev_eng_ret(current_price) do 
    
  end

  #1. calculate avg FCF
  def avg_fcf do 
    values = get_fcf()

    total_fcf = Enum.reduce(values, fn(x, acc) -> x + acc end)

    #number of years
    periods = periods()

    total_fcf / periods |> round()
  end

  #2.Growth rate of cash flows over 10 yrs
  def fcf_growth do 
     %HTTPoison.Response{body: resp} = 
       HTTPoison.get! @base_url <> 
       "historical_data?identifier=#{@ticker}"
       <> "&item=netincome&frequency=yearly", 
       @headers

     data = resp |> Poison.decode! |> Map.get("data")

     values = 
      Stream.filter(data, &(Map.get(&1, "value") != nil))
      |> Enum.map(fn(x) -> Map.get(x, "value") end)

      # (new/old)^(1/n)-1)*100 
      ################################
      # periods between net incomes - 1
      periods = Enum.count(values) - 1
      ## new/old
      val_quotient = (List.first(values)/List.last(values))
      # exponent in decimal
      exponent = 1 / periods

      ((:math.pow(val_quotient, exponent)) - 1) * 100
        |> Float.round(2)
  end

  #fcf in 10 years
  #fv = avg_fcf(1+g)^n + avg_fcf
  def future_fcf(year \\ 1, acc \\ []) do 
    periods = periods()
    growth = fcf_growth() / 100
    start = avg_fcf()

    new_item = 
      start * :math.pow((1 + growth), year) |> round

    future_fcf_list = [ new_item | acc ]

    case Enum.count(acc) do 
      ^periods -> acc
      _ -> future_fcf(year + 1, future_fcf_list)
    end

  end

  #discount factor
  #(1 + g) ^ n 
  def df(disc_rate, year \\ 1, acc \\ []) do 
    periods = periods()
    rate_dec = disc_rate / 100 
    result = :math.pow(1 + rate_dec, year)

    df_list = [ result |> Float.round(2)  | acc]

    case Enum.count(acc) do
      ^periods -> acc
      _ -> df(disc_rate, year + 1, df_list)
    end
  end

  # FCF_1 * DF_1  
  # FCF_2 * DF_2
  def dfcf(rate) do 
    #future fcfs 
    fcf_list = future_fcf()
    #df
    df_list = df(rate)

    Stream.zip(fcf_list, df_list) 
      |> Stream.map(fn{a,b} -> a / b  end)
      |> Stream.map(&(round(&1)))
      |> Enum.sum
  end

  def dpcf(rate) do 
    perp_rate = 0.03
    fcf = List.first(future_fcf())
    disc_rate = rate / 100
    #perpetuity value
    #(CFn x (1+ g)) / (R - g)
    #CF at year N
    cf = (fcf * (1 + perp_rate)) / (disc_rate - perp_rate)

    #Present Value of Cash Flow in Year N =
    # CF at Year N / (1 + R)^N
    #
    # Present value of perpetuity value
    denominator = :math.pow((1 + disc_rate), 8)

    cf / denominator
  end

  defp get_fcf do 
    %HTTPoison.Response{body: resp} = 
       HTTPoison.get! @base_url <> 
       "historical_data?identifier=#{@ticker}"
       <> "&item=freecashflow&frequency=yearly", 
       @headers

      data = resp |> Poison.decode! |> Map.get("data")

      #get only the value keys
      #from items that contain != nil value
       Stream.filter(data, &(Map.get(&1, "value") != nil))
       |> Enum.map(&(Map.get(&1, "value")))
       |> Enum.map(&(round(&1)))
  end
  
  defp periods do 
    %HTTPoison.Response{body: resp} = 
       HTTPoison.get! @base_url <> 
       "historical_data?identifier=#{@ticker}"
       <> "&item=freecashflow&frequency=yearly", 
       @headers

    data = resp |> Poison.decode! |> Map.get("data")

    #get only the value keys
    #from items that contain != nil value
    Stream.filter(data, &(Map.get(&1, "value") != nil))
    |> Enum.count
  end
end
