defmodule IV do 
  @base_url Utils.return_base()
  @headers Utils.return_headers()
  @ticker Utils.load_ticker()

  #Div*(1-(1/(1+i)^n)/i + FV/(1+i)^n
  #rate refers to interest rate
  def intrinsic_val(rate) do 
    div = Info.avg_dividend
    future_bv = future_val()
    rate_dec = rate / 100 |> Float.round(4)

    div * ((1-(1/iv_helper(rate_dec))) / rate_dec) + future_bv/iv_helper(rate_dec)
    #0.80*(1-(1/(:math.pow(1.0238, 10))))/0.0238 + 27.5 * (:math.pow((1.0666988)/(1+0.0238), 10))
    #0.8*(1-(1/((1 + 0.0238)^10)))/0.0238 + 27.5*(((1 + 0.066698)/(1+0.0238))^10)
  end

  defp iv_helper(rate) do 
    :math.pow(1 + rate, 10)
  end

  def book_values do 
    bv_helper()
  end

  #book value avg % change
  #year over year
  def bv_growth() do 
    values = bv_helper()

      #(new/old)^(1/9)-1)*100 
      ################################
      #periods between book values - 1
      periods = Enum.count(values) - 1
      #new/old
      quotient = (List.first(values)/List.last(values))
      #exp = :math.pow()
      exponent = 1 / periods

      ((:math.pow(quotient, exponent)) - 1) * 100
  end

  #calculate Future Value
  #PV * ( 1 + bv_growth )^n
  def future_val do 
    %HTTPoison.Response{body: resp} = 
       HTTPoison.get! @base_url <> 
       "historical_data?ticker=#{@ticker}"
       <> "&item=bookvaluepershare&frequency=yearly", 
       @headers

    data = resp |> Poison.decode! |> Map.get("data")

    #get only the value keys
    #from items that contain != nil value
    periods = 
       Stream.filter(data, &(Map.get(&1, "value") != nil))
       |> Enum.count

     present_bv = 
       Stream.filter(data, &(Map.get(&1, "value") != nil))
       |> Enum.map(&(Map.get(&1, "value")))
       |> List.first

    bv_growth = bv_growth() / 100

    exp = :math.pow((1 + bv_growth), periods)
    present_bv * exp |> Float.round(2)
  end

  #1 - Current Price / Intrinsic Value
  def mos(rate) do 
    curr_price = Info.last_price()
    iv_val = intrinsic_val(rate)
    1 - (curr_price / iv_val)
  end

  defp bv_helper do 
     %HTTPoison.Response{body: resp} = 
       HTTPoison.get! @base_url <> 
       "historical_data?ticker=#{@ticker}"
       <> "&item=bookvaluepershare&frequency=yearly", 
       @headers

      data = resp |> Poison.decode! |> Map.get("data")

      #get only the value keys
      #from items that contain != nil value
      Enum.filter(data, &(Map.get(&1, "value") != nil))
      |> Enum.map(fn(x) -> Map.get(x, "value") end)
  end

end
