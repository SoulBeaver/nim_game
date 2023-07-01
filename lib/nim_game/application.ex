defmodule NimGame.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    IO.puts("Starting Nim Game")

    children = [
      {Registry, [name: NimGame.Registry.GameSession, keys: :unique]},
      {DynamicSupervisor, [name: NimGame.Supervisor.GameSession, strategy: :one_for_one]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NimGame.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
