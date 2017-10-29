defmodule Utils do 
  use Agent
  @username Application.get_env(:stockex, :username)
  @password Application.get_env(:stockex, :password)
  @base_url "https://api.intrinio.com/"
  @headers %{"Authorization" => "Basic " <> Base.encode64("#{@username}:#{@password}")}

  def return_headers do 
    @headers
  end

  def return_base do 
    @base_url
  end

  def prices_url(symbol) do
    "prices?ticker=#{symbol}"
  end

  def page_loop(current_page \\ 1, acc \\ []) do 
    %HTTPoison.Response{body: response} = 
      HTTPoison.get! @base_url <> "prices?ticker=SNAP" <>
      "&page_number=#{current_page}", @headers 

    data = response |> process_resp() |> Map.get("data")
    data_list = [data | acc]

    case get_total_pages(response) do 
      ^current_page -> List.flatten data_list
      _ -> page_loop(current_page + 1, data_list)
    end
  end


  ## decode JSON & get # of pages by 
  ## accessing "total_pages" key
  defp get_total_pages(resp) do 
    process_resp(resp) |> Map.get("total_pages")
  end

  #decode the JSON
  defp process_resp(data) do 
    Poison.decode! data
  end
end

