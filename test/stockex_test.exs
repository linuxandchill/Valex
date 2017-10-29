defmodule StockexTest do
  use ExUnit.Case
  doctest Stockex

  test "greets the world" do
    assert Stockex.hello() == :world
  end
end
