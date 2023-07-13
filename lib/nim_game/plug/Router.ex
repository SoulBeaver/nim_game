defmodule NimGame.Plug.Router do
  use Plug.Router

  if Mix.env() == :dev do
    use Plug.Debugger
  end

  use Plug.ErrorHandler

  alias NimGame.Core.{Game, Matchsticks}
  alias NimGame.Boundary.GameSession
  alias NimGame.Plug.VerifyRequest

  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)

  plug(VerifyRequest,
    fields: [],
    paths: ["/game", "/game/:session_id", "/game/:session_id/restart"]
  )

  plug(:match)
  plug(:dispatch)

  # Start a game of Nim
  post "/game" do
    %{"player" => player, "matchsticks" => matchsticks} = conn.body_params

    new_game_information =
      GameSession.start_game(
        matchsticks,
        player,
        rand_session_id()
      )

    send_json(conn, new_game_information)
  end

  # Get the state of the game
  get "/game/:session_id" do
    send_json(conn, GameSession.game_status(session_id))
  end

  # Play a turn of Nim
  post "/game/:session_id" do
    %{"matchsticks" => matchsticks} = conn.body_params

    case GameSession.take_matchsticks(matchsticks, session_id) do
      {%Game{} = game, session_id} ->
        send_json(conn, {game, session_id})

      {:error, _message} = error ->
        send_json(conn, error)
    end
  end

  # Restart a running or finished game of Nim
  post "/game/:session_id/restart" do
    %{"matchsticks" => matchsticks} = conn.body_params

    restarted_game_information = GameSession.restart_game(matchsticks, session_id)

    send_json(conn, restarted_game_information)
  end

  match _ do
    send_resp(conn, 404, "Oops!")
  end

  defp handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
    IO.inspect(kind, label: :kind)
    IO.inspect(reason, label: :reason)
    IO.inspect(stack, label: :stack)

    send_resp(conn, conn.status, "Something went wrong")
  end

  defp send_json(conn, {:error, _message} = error) do
    body = Jason.encode!(prepare_error(error))
    send_resp(conn, 400, body)
  end

  defp send_json(%{status: status} = conn, {game_data, session_id}) do
    body = Jason.encode!(prepare(game_data, session_id))
    send_resp(conn, status || 200, body)
  end

  defp prepare(
         %Game{
           player: player,
           difficulty: difficulty,
           game_state: {:running, %Matchsticks{matchsticks: matchsticks}}
         },
         session_id
       ) do
    %{
      session_id: session_id,
      player: player,
      difficulty: difficulty,
      game_state: %{status: :running, matchsticks: matchsticks}
    }
  end

  defp prepare(
         %Game{
           player: player,
           difficulty: difficulty,
           game_state: {:game_over, winner}
         },
         session_id
       ) do
    %{
      session_id: session_id,
      player: player,
      difficulty: difficulty,
      game_state: %{status: :game_over, winner: winner}
    }
  end

  defp prepare_error({:error, message}) do
    %{error: message}
  end

  defp rand_session_id(), do: :rand.uniform(1_000_000_000) |> to_string()
end
