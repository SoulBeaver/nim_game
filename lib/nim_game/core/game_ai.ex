defmodule NimGame.Core.GameAi do
  alias NimGame.Core.{Game, Matchsticks}

  @type difficulty :: :easy | :hard

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
