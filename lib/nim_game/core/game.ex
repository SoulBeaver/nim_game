defmodule NimGame.Core.Game do
  @moduledoc """
  Represents a game session in which a person or computer player can
  take matches from a running match game. The game will determine the winner and loser.
  """

  alias NimGame.Core.Matchsticks

  defstruct player: nil,
            difficulty: :easy,
            game_state: :not_started

  @type player :: String.t()
  @type winner :: String.t()

  @type difficulty :: :easy | :hard

  @type game_state ::
          {:running, Matchsticks.t()}
          | {:game_over, winner}

  @type t() :: %__MODULE__{
          player: String.t(),
          difficulty: difficulty,
          game_state: game_state
        }

  @doc """
  Starts a new game of Nim

  Examples:

    iex> Game.start_game("a")
    %Game{player: "a", game_state: {:running, %Matchsticks{matchsticks: 13}}}

    iex> Game.start_game("a", 10)
    %Game{player: "a", game_state: {:running, %Matchsticks{matchsticks: 10}}}

    iex> Game.start_game("a", 0)
    {:error, :invalid_matchsticks_number}
  """
  @spec start_game(player, pos_integer(), difficulty()) ::
          t() | {:error, :invalid_matchsticks_number}
  def start_game(player, number_matchsticks \\ 13, difficulty \\ :easy) do
    case Matchsticks.new(number_matchsticks) do
      %Matchsticks{} = matchsticks ->
        %__MODULE__{player: player, difficulty: difficulty, game_state: {:running, matchsticks}}

      error ->
        error
    end
  end

  @doc """
  Restarts the game

  Examples:

    iex> Game.start_game("a") |> Game.restart_game(15)
    %Game{player: "a", game_state: {:running, %Matchsticks{matchsticks: 15}}}
  """
  @spec restart_game(t(), pos_integer()) :: t() | {:error, :invalid_matchsticks_number}
  def restart_game(game, number_matchsticks \\ 13) do
    player = Map.get(game, :player)

    start_game(player, number_matchsticks)
  end

  @doc """
  Takes a number of matches from the pile and checks for game end.
  """
  @spec take_matchsticks(t(), player, pos_integer()) ::
          t()
          | {:error, :game_not_running}
          | {:error, :not_enough_matchsticks}
          | {:error, :invalid_number_of_matchsticks}
  def take_matchsticks(
        %__MODULE__{game_state: {:running, matchsticks}} = game,
        active_player,
        number_to_take
      ) do
    case Matchsticks.take_matchsticks(matchsticks, number_to_take) do
      %Matchsticks{} = new_matchsticks ->
        maybe_finish(game, new_matchsticks, active_player)

      error ->
        error
    end
  end

  def take_matchsticks(_game, _active_player, _number_to_take),
    do: {:error, :game_not_running}

  @spec maybe_finish(t(), Matchsticks.t(), player) :: t()
  defp maybe_finish(game, %Matchsticks{matchsticks: 0}, winning_player) do
    %__MODULE__{game | game_state: {:game_over, winning_player}}
  end

  defp maybe_finish(game, new_matchsticks, _player) do
    %__MODULE__{game | game_state: {:running, new_matchsticks}}
  end
end
