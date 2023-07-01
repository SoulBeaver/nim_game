defmodule NimGame.Core.NimGame do
  @moduledoc """
  Represents a game session in which a person or computer player can
  take matches from a running match game. The game will determine the winner and loser.
  """

  alias NimGame.Core.Matchsticks

  defstruct player_one: nil,
            player_two: nil,
            game_state: :not_started

  @type winner :: String.t()
  @type loser :: String.t()

  @type game_state ::
          :not_started
          | {:running, Matchsticks.t()}
          | {:game_over, winner: winner}

  @type t() :: %__MODULE__{
          player_one: String.t(),
          player_two: String.t(),
          game_state: game_state
        }

  @doc """
  Starts a new game of Nim

  Examples:

    iex> NimGame.start_game("a", "b")
    %NimGame{player_one: "a", player_two: "b", game_state: {:running, %Matchsticks{matchsticks: 13}}}

    iex> NimGame.start_game("a", "b", 10)
    %NimGame{player_one: "a", player_two: "b", game_state: {:running, %Matchsticks{matchsticks: 10}}}
  """
  @spec start_game(String.t(), String.t(), pos_integer()) :: t()
  def start_game(player_one, player_two, number_matchsticks \\ 13) do
    %__MODULE__{
      player_one: player_one,
      player_two: player_two,
      game_state: {:running, Matchsticks.new(number_matchsticks)}
    }
  end

  @doc """
  Takes a number of matches from the pile and checks for game end.
  """
  @spec take_matchsticks(t(), String.t(), pos_integer()) :: t() | {:error, :game_not_running}
  def take_matchsticks(
        %__MODULE__{game_state: {:running, matchsticks}} = game,
        active_player,
        number_to_take
      ) do
    case Matchsticks.take_matchsticks(matchsticks, number_to_take) do
      %Matchsticks{} = new_matchsticks -> maybe_finish(game, new_matchsticks, active_player)
      error -> error
    end
  end

  def take_matchsticks(_game, _active_player, _number_to_take),
    do: {:error, :game_not_running}

  defp maybe_finish(
         game,
         %Matchsticks{matchsticks: 0},
         winning_player
       ) do
    %__MODULE__{game | game_state: {:game_over, winning_player}}
  end

  defp maybe_finish(game, new_matchsticks, _active_player),
    do: %__MODULE__{game | game_state: {:running, new_matchsticks}}
end
