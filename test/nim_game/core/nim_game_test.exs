defmodule NimGame.Core.NimGameTest do
  use ExUnit.Case, async: true

  alias NimGame.Core.{Matchsticks, NimGame}

  doctest NimGame

  defp running_game(context) do
    {:ok, Map.put(context, :game, NimGame.start_game("a", 13))}
  end

  defp finished_game(context) do
    running_game = NimGame.start_game("a", 3)
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

    test "can be restarted", %{game: game} do
      %NimGame{game_state: {:running, %Matchsticks{matchsticks: matchsticks}}} =
        NimGame.restart_game(game, 15)

      assert matchsticks == 15
    end
  end

  describe "a game" do
    test "can be played from start to finish" do
      %NimGame{game_state: {:game_over, winner}} =
        NimGame.start_game("a")
        |> run_game_until_complete()

      assert winner in ["a", "PC"]
    end
  end

  defp run_game_until_complete(%NimGame{game_state: {:running, _}} = game) do
    game
    |> NimGame.take_matchsticks("a", 1)
    |> run_game_until_complete()
  end

  defp run_game_until_complete(%NimGame{game_state: {:game_over, _}} = game) do
    game
  end
end
