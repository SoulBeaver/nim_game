defmodule NimGame.Core.NimGameAi do
  alias NimGame.Core.NimGame

  @type difficulty :: :easy | :hard

  @spec determine_matchstick_number(NimGame.t()) :: integer()
  def determine_matchstick_number(game)

  def determine_matchstick_number(%NimGame{difficulty: :easy, game_state: {:running, _matchsticks}}) do
    1
  end

  def determine_matchstick_number(%NimGame{difficulty: :hard, game_state: {:running, _matchsticks}}) do
    1
  end

  def determine_matchstick_number(%NimGame{game_state: {:game_over, _}} = game) do
    game
  end
end
