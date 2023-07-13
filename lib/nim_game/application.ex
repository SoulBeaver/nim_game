defmodule NimGame.Application do
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    IO.puts("Starting Nim Game")

    children = [
      {Registry, [name: NimGame.Registry.GameSession, keys: :unique]},
      {DynamicSupervisor, [name: NimGame.Supervisor.GameSession, strategy: :one_for_one]},
      {Plug.Cowboy, scheme: :http, plug: NimGame.Plug.Router, options: [port: cowboy_port()]}
    ]

    Logger.info("Starting application")

    opts = [strategy: :one_for_one, name: NimGame.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp cowboy_port,
    do: Application.get_env(:nim_game, :cowboy_port, 8080)
end
