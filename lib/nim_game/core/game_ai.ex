defmodule NimGame.Core.GameAi do
  @moduledoc """
  Rudimentary AI capable of playing a game of Nim
  """

  alias NimGame.Core.{Game, Matchsticks}

  @type difficulty :: :easy | :hard

  @doc """
  Determines how many matchsticks the AI should take for its turn
  """
  @spec determine_matchstick_number(Game.t()) :: integer()
  def determine_matchstick_number(game)

  def determine_matchstick_number(%Game{
        difficulty: :easy,
        game_state: {:running, %Matchsticks{matchsticks: matchsticks}}
      }) do
    :rand.uniform(min(matchsticks, 3))
  end

  def determine_matchstick_number(%Game{
    difficulty: :hard,
    game_state: {:running, %Matchsticks{matchsticks: matchsticks}}
  }) do
    # Trust me, super sophisticated
    :rand.uniform(min(matchsticks, 3))
  end

  def determine_matchstick_number(%Game{game_state: {:game_over, _}} = game) do
    game
  end
end
