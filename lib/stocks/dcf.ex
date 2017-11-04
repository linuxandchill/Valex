defmodule DCF do 
  @base_url Utils.return_base()
  @headers Utils.return_headers()
  @ticker Utils.load_ticker()

  #1. calculate avg FCF
  def avg_fcf do 
     %HTTPoison.Response{body: resp} = 
       HTTPoison.get! @base_url <> 
       "historical_data?identifier=#{@ticker}"
       <> "&item=freecashflow&frequency=yearly", 
       @headers

      data = resp |> Poison.decode! |> Map.get("data")

      #get only the value keys
      #from items that contain != nil value
      values = 
        Stream.filter(data, &(Map.get(&1, "value") != nil))
        |> Stream.map(&(Map.get(&1, "value")))
        |> Enum.map(&(round(&1)))

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
  #fv = avg_fcf(1+g)^n
  def future_fcf do 
    data = get_fcf()
    periods = periods()
    growth = fcf_growth() / 100
    start = avg_fcf()

    exp = :math.pow((1 + fcf_growth), periods)
    start * exp |> round()

    count = 8

    case periods do 
      ^count -> IO.puts "matches"
      _ -> IO.puts "no match"
    end
  end

  #discount factor
  #(1 + g) ^ n 
  def df(disc_rate, year \\ 1, acc \\ []) do 
    periods = periods()
    rate_dec = disc_rate / 100 
    result = :math.pow(1 + rate_dec, 1)

    df_list = [ result  | acc]

    case Enum.count(acc) do

    end
  end

  def dfcf(rate) do 
    rate
    #fcf / df
  end

  defp get_disc_rate do 
   disc_rate = IO.gets "Enter discount rate: "
   disc_rate
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
