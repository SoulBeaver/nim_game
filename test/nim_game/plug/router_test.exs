defmodule NimGame.Plug.RouterTest do
  use ExUnit.Case

  use Plug.Test

  alias NimGame.Plug.Router

  @opts Router.init([])

  test "starts a new game" do
    conn =
      :post
      |> conn("/game", %{"player" => "Christian", "matchsticks" => 13})
      |> Router.call(@opts)

    %{
      "player" => "Christian",
      "difficulty" => "easy",
      "game_state" => %{"matchsticks" => 13, "status" => "running"},
      "session_id" => _session_id
    } = Jason.decode!(conn.resp_body)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "can take matchsticks" do
    session_id =
      :post
      |> conn("/game", %{"player" => "Christian", "matchsticks" => 13})
      |> Router.call(@opts)
      |> read_session_id()

    conn =
      :post
      |> conn("/game/#{session_id}", %{"matchsticks" => 3})
      |> Router.call(@opts)

    %{
      "player" => "Christian",
      "difficulty" => "easy",
      "game_state" => %{"matchsticks" => matchsticks, "status" => "running"},
      "session_id" => _session_id
    } = Jason.decode!(conn.resp_body)

    assert conn.state == :sent
    assert conn.status == 200
    assert matchsticks in Enum.to_list(7..9) # The AI takes 1-3 matchsticks
  end

  test "can restart game" do
    session_id =
      :post
      |> conn("/game", %{"player" => "Christian", "matchsticks" => 13})
      |> Router.call(@opts)
      |> read_session_id()

    conn =
      :post
      |> conn("/game/#{session_id}/restart", %{"matchsticks" => 20})
      |> Router.call(@opts)

    %{
      "player" => "Christian",
      "difficulty" => "easy",
      "game_state" => %{"matchsticks" => matchsticks, "status" => "running"},
      "session_id" => _session_id
    } = Jason.decode!(conn.resp_body)

    assert conn.state == :sent
    assert conn.status == 200
    assert matchsticks == 20
  end

  defp read_session_id(conn) do
    conn.resp_body
    |> Jason.decode!()
    |> Map.get("session_id")
  end
end
