defmodule NimGame.Core.NimGameTest do
  use ExUnit.Case, async: true

  alias NimGame.Core.{NimGame, Matchsticks}

  doctest NimGame

  defp running_game(context) do
    {:ok, Map.put(context, :game, NimGame.start_game("a", "b", 13))}
  end

  defp finished_game(context) do
    running_game = NimGame.start_game("a", "b", 3)
    finished_game = NimGame.take_matchsticks(running_game, "a", 3)

    {:ok, Map.put(context, :game, finished_game)}
  end

  describe "a running game" do
    setup [:running_game]

    test "has matchsticks remaining", %{game: %NimGame{game_state: running_game}} do
      {:running, %Matchsticks{matchsticks: matchsticks_remaining}} = running_game

      assert matchsticks_remaining == 13
    end

    test "can take matchsticks from pile", %{game: game} do
      %NimGame{game_state: {:running, %Matchsticks{matchsticks: matchsticks_remaining}}} =
        NimGame.take_matchsticks(game, "a", 3)

      assert matchsticks_remaining == 10
    end
  end

  describe "a finished game" do
    setup [:finished_game]

    test "has a winner", %{game: %NimGame{game_state: finished_game}} do
      {:game_over, winning_player} = finished_game

      assert winning_player == "a"
    end

    test "can't take anymore matchsticks", %{game: game} do
      assert NimGame.take_matchsticks(game, "a", 3) == {:error, :game_not_running}
    end
  end
end
