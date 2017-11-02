defmodule Utils do 
  @username Application.get_env(:stockex, :username)
  @password Application.get_env(:stockex, :password)
  @base_url "https://api.intrinio.com/"
  @headers %{"Authorization" => "Basic " <> Base.encode64("#{@username}:#{@password}")}

  def return_headers do @headers
  end

  def return_base do 
    @base_url
  end

  # def prices_url(symbol) do
  # de"prices?ticker=#{symbol}"
  # end

  def page_loop(current_page \\ 1, acc \\ [], ticker \\ "") do 
    %HTTPoison.Response{body: response} = 
      HTTPoison.get! @base_url <> "prices?ticker=#{ticker}" <>
      "&page_number=#{current_page}", @headers 

    data = response |> process_resp() |> Map.get("data")
    data_list = [data | acc]

    case get_total_pages(response) do 
      ^current_page -> List.flatten data_list
      _ -> page_loop(current_page + 1, data_list, ticker)
    end
  end

  ## decode JSON & get # of pages by 
  ## accessing "total_pages" key
  defp get_total_pages(resp) do 
    process_resp(resp) |> Map.get("total_pages")
  end

  #decode the JSON
  def process_resp(data) do 
    Poison.decode! data
  end

  def load_ticker() do 
     ticker = IO.gets "Enter symbol: "
     ticker = 
       ticker
       |> String.upcase
       |> String.trim
     IO.puts "Now conducting analysis on #{ticker}"
     ticker
  end

  defp subtract(x, y) do
      x - y
  end

  def average(list), do: Enum.sum(list) / length(list)

end

