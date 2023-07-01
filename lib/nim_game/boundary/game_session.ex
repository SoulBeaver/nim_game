defmodule NimGame.Boundary.GameSession do
  @moduledoc """
  Runs a game of Nim between a player and an AI.
  """

  alias NimGame.Core.Matchsticks

  use GenServer

  def child_spec(session_id) do
    %{
      id: {__MODULE__, session_id},
      start: {__MODULE__, :start_link, [session_id]},
      restart: :temporary
    }
  end

  @spec start_link({pos_integer(), pos_integer()}) :: {:ok, pid()}
  def start_link({matchsticks, session_id} = state) do
    GenServer.start_link(
      __MODULE__,
      state,
      name: via(session_id)
    )
  end

  def start_game(matchsticks \\ 13, session_id) do
    DynamicSupervisor.start_child(
      NimGame.Supervisor.GameSession,
      {__MODULE__, {matchsticks, session_id}}
    )
  end

  def restart_game(matchsticks \\ 13, session_id) do
    GenServer.call(via(session_id), {:restart_game, matchsticks})
  end

  def take_matchsticks(session_id, amount) do
    GenServer.call(via(session_id), {:take_matchsticks, amount})
  end

  def take_matchsticks_2(server_id, amount) do
    GenServer.call(server_id, {:take_matchsticks, amount})
  end

  # Server-side calls

  @impl true
  def init({matchsticks, session_id}) do
    IO.puts("Registered new session with id #{session_id} and #{matchsticks} matchsticks")
    {:ok, {Matchsticks.new(matchsticks), session_id}}
  end

  @impl true
  def handle_call({:take_matchsticks, amount}, _from, {matchsticks, session_id}) do
    with matchsticks <- Matchsticks.take_matchsticks(matchsticks, amount) do
      {:reply, matchsticks, {matchsticks, session_id}}
    else
      error -> error
    end
  end

  @impl true
  def handle_call({:restart_game, matchsticks}, _from, {matchsticks, session_id}) do
    new_game = Matchsticks.new(matchsticks)
    {:reply, new_game, {new_game, session_id}}
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
