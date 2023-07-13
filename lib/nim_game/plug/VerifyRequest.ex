defmodule NimGame.Plug.VerifyRequest do
  defmodule IncompleteRequestError do
    @moduledoc """
    Error raised when a required field is missing.
    """

    defexception message: "", plug_status: 400
  end

  require Logger

  def init(options), do: options

  def call(%Plug.Conn{request_path: "/game"} = conn, _opts) do
    verify_request!(conn.params, [:player], [:matchsticks])

    Logger.info("Verified POST /game")

    conn
  end

  def call(%Plug.Conn{request_path: "/game/:session_id"} = conn, _opts) do
    verify_request!(conn.params, [:matchsticks_to_take], [])

    Logger.info("Verified POST /game/:session_id")

    conn
  end

  def call(%Plug.Conn{request_path: "/game/:session_id/restart"} = conn, _opts) do
    verify_request!(conn.params, [:matchsticks], [])

    Logger.info("Verified POST /game/:session_id/restart")

    conn
  end

  def call(%Plug.Conn{request_path: path} = conn, _opts) do
    Logger.info("Couldn't match against path #{path}")

    conn
  end

  defp verify_request!(params, mandatory_fields, _optional_fields) do
    IO.inspect(params, label: :params)

    verified =
      params
      |> Map.keys()
      |> Enum.map(&(String.to_atom(&1)))
      |> contains_fields?(mandatory_fields)

    unless verified, do: raise(IncompleteRequestError)
  end

  defp contains_fields?(keys, fields),
    do: Enum.all?(fields, &(&1 in keys))
end
