defmodule Calcs do 
  @base_url Utils.return_base()
  @headers Utils.return_headers()
  @ticker Utils.load_ticker()

  # Div*(1-(1/(1+i)^n))/i+FBV/(1+i)^n
  def intrinsic_val(rate) do 
    div = Info.avg_dividend

    #(1+i)^n)
    helper = (1+rate)
    ((:math.pow(quotient, exponent)) - 1) * 100
    #div*(1-(1/(1+rate)))
  end

  #book value avg % change
  #year over year
  defp bv_growth() do 
     %HTTPoison.Response{body: resp} = 
       HTTPoison.get! @base_url <> 
       "historical_data?ticker=#{@ticker}"
       <> "&item=bookvaluepershare&frequency=yearly", 
       @headers

      data = resp |> Poison.decode! |> Map.get("data")

      #get only the value keys
      #from items that contain != nil value
       values = 
         Enum.filter(data, &(Map.get(&1, "value") != nil))
         |> Enum.map(fn(x) -> Map.get(x, "value") end)

      #(new/old)^(1/9)-1)*100 ###############################
      #periods between book values - 1
      periods = Enum.count(values) - 1
      #new/old
      quotient = (List.first(values)/List.last(values))
      #exp = :math.pow()
      exponent = 1 / periods

      ((:math.pow(quotient, exponent)) - 1) * 100
  end

  #PV(1+i)^n
  defp future_bv do 
    %HTTPoison.Response{body: resp} = 
     HTTPoison.get! @base_url <> 
     "historical_data?ticker=#{@ticker}"
     <> "&item=bookvaluepershare&frequency=yearly", 
     @headers

    data = resp |> Poison.decode! |> Map.get("data")

    #get only the value keys
    #from items that contain != nil value
     values = 
       Enum.filter(data, &(Map.get(&1, "value") != nil))
       |> Enum.map(fn(x) -> Map.get(x, "value") end)
      
    pv = List.first(values)
    bv_growth = bv_growth() / 100
    exp = (1+bv_growth)(:math.pow(quotient, exponent)
  end

  def mos do 
  end

end
