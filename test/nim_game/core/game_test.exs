defmodule NimGame.Core.GameTest do
  use ExUnit.Case, async: true

  alias NimGame.Core.{Matchsticks, Game}

  doctest Game

  defp running_game(context) do
    {:ok, Map.put(context, :game, Game.start_game("a", 13))}
  end

  defp finished_game(context) do
    running_game = Game.start_game("a", 3)
    finished_game = Game.take_matchsticks(running_game, "a", 3)

    {:ok, Map.put(context, :game, finished_game)}
  end

  describe "a running game" do
    setup [:running_game]

    test "has matchsticks remaining", %{game: %Game{game_state: running_game}} do
      {:running, %Matchsticks{matchsticks: matchsticks_remaining}} = running_game

      assert matchsticks_remaining == 13
    end

    test "can take matchsticks from pile", %{game: game} do
      %Game{game_state: {:running, %Matchsticks{matchsticks: matchsticks_remaining}}} =
        Game.take_matchsticks(game, "a", 3)

      assert matchsticks_remaining == 10
    end
  end

  describe "a finished game" do
    setup [:finished_game]

    test "has a winner", %{game: %Game{game_state: finished_game}} do
      {:game_over, winning_player} = finished_game

      assert winning_player == "a"
    end

    test "can't take anymore matchsticks", %{game: game} do
      assert Game.take_matchsticks(game, "a", 3) == {:error, :game_not_running}
    end

    test "can be restarted", %{game: game} do
      %Game{game_state: {:running, %Matchsticks{matchsticks: matchsticks}}} =
        Game.restart_game(game, 15)

      assert matchsticks == 15
    end
  end

  describe "a game" do
    test "can be played from start to finish" do
      %Game{game_state: {:game_over, winner}} =
        Game.start_game("a")
        |> run_game_until_complete()

      assert winner in ["a", "PC"]
    end
  end

  defp run_game_until_complete(%Game{game_state: {:running, _}} = game) do
    game
    |> Game.take_matchsticks("a", 1)
    |> run_game_until_complete()
  end

  defp run_game_until_complete(%Game{game_state: {:game_over, _}} = game) do
    game
  end
end
