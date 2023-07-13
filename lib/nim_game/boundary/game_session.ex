defmodule NimGame.Boundary.GameSession do
  @moduledoc """
  Runs a game of Nim between a player and the computer
  """

  alias NimGame.Core.{Game, GameAi}

  use GenServer

  @type player :: String.t()
  @type session_id :: pos_integer()
  @type matchsticks :: pos_integer()

  def child_spec(session_id) do
    %{
      id: {__MODULE__, session_id},
      start: {__MODULE__, :start_link, [session_id]},
      restart: :temporary
    }
  end

  @spec start_link({matchsticks, player, session_id}) :: {:ok, pid()}
  def start_link({_matchsticks, _player, session_id} = state) do
    GenServer.start_link(
      __MODULE__,
      state,
      name: via(session_id)
    )
  end

  @spec start_game(matchsticks, player, session_id) :: any()
  def start_game(matchsticks \\ 13, player, session_id) do
    with {:ok, _pid} <-
           DynamicSupervisor.start_child(
             NimGame.Supervisor.GameSession,
             {__MODULE__, {matchsticks, player, session_id}}
           ) do
      GenServer.call(via(session_id), :game_status)
    else
      error -> error
    end
  end

  def restart_game(matchsticks \\ 13, session_id) do
    GenServer.call(via(session_id), {:restart_game, matchsticks})
  end

  def take_matchsticks(amount, session_id) do
    GenServer.call(via(session_id), {:take_matchsticks, amount})
  end

  def game_status(session_id) do
    GenServer.call(via(session_id), :game_status)
  end

  # Server-side calls

  @impl true
  @spec init({matchsticks, player, session_id}) :: {:ok, {Game.t(), session_id}}
  def init({matchsticks, player, session_id}) do
    {:ok, {Game.start_game(player, matchsticks), session_id}}
  end

  @impl true
  def handle_call({:take_matchsticks, amount}, _from, {game, session_id}) do
    case game do
      %Game{player: _, difficulty: _, game_state: {:game_over, _}} ->
        {:reply, {:error, :game_not_running}, {game, session_id}}

      _ ->
        human_player = Map.get(game, :player)

        updated_game_state = perform_human_turn(game, human_player, amount)

        {:reply, {updated_game_state, session_id}, {updated_game_state, session_id}}
    end
  end

  @impl true
  def handle_call({:restart_game, matchsticks}, _from, {game, session_id}) do
    restarted_game = Game.restart_game(game, matchsticks)

    {:reply, {restarted_game, session_id}, {restarted_game, session_id}}
  end

  @impl true
  def handle_call(:game_status, _from, {game, session_id}) do
    {:reply, {game, session_id}, {game, session_id}}
  end

  defp perform_human_turn(game, human_player, amount) do
    case Game.take_matchsticks(game, human_player, amount) do
      %Game{game_state: {:running, _}} = human_turn ->
        perform_ai_turn(human_turn)

      %Game{game_state: {:game_over, _}} = finished_game ->
        finished_game

      error ->
        error
    end
  end

  defp perform_ai_turn(game) do
    matchsticks_to_take = GameAi.determine_matchstick_number(game)

    Game.take_matchsticks(game, "PC", matchsticks_to_take)
  end

  # Routing key

  def via(session_id) do
    {
      :via,
      Registry,
      {NimGame.Registry.GameSession, session_id}
    }
  end
end
