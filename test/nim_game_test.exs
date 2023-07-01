defmodule NimGameTest do
  use ExUnit.Case
  doctest NimGame

  test "greets the world" do
    assert NimGame.hello() == :world
  end
end
