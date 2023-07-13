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

    conn
  end

  def call(%Plug.Conn{request_path: "/game/*"} = conn, _opts) do
    verify_request!(conn.params, [:matchsticks_to_take], [])

    conn
  end

  def call(%Plug.Conn{request_path: "/game/*/restart"} = conn, _opts) do
    verify_request!(conn.params, [:matchsticks], [])

    conn
  end

  def call(%Plug.Conn{request_path: _path} = conn, _opts) do
    conn
  end

  defp verify_request!(params, mandatory_fields, _optional_fields) do
    verified =
      params
      |> Map.keys()
      |> Enum.map(&String.to_atom(&1))
      |> contains_fields?(mandatory_fields)

    unless verified, do: raise(IncompleteRequestError)
  end

  defp contains_fields?(keys, fields),
    do: Enum.all?(fields, &(&1 in keys))
end
