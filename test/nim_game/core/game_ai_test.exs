defmodule NimGame.Core.GameAITest do
  use ExUnit.Case, async: true

  alias NimGame.Core.{Game, GameAi}

  test "takes the last matchstick" do
    game = Game.start_game("Test", 1)

    assert GameAi.determine_matchstick_number(game) == 1
  end
end
