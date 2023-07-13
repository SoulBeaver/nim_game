defmodule NimGame.Core.Matchsticks do
  @moduledoc """
  Represents a pile of matchsticks and allows for someone to take 1, 2 or 3 matchsticks from the pile.
  """

  @type t() :: %__MODULE__{matchsticks: integer()}

  @derive Jason.Encoder
  defstruct matchsticks: 13

  @doc """
  Creates a new pile of matchsticks

  Examples:

    iex> NimGame.Core.Matchsticks.new(13)
    %NimGame.Core.Matchsticks{matchsticks: 13}
  """
  @spec new(integer()) :: t() | {:error, :invalid_matchsticks_number}
  def new(matchsticks)

  def new(matchsticks) when matchsticks <= 0, do: {:error, :invalid_matchsticks_number}

  def new(matchsticks) do
    %__MODULE__{matchsticks: matchsticks}
  end

  @doc """
  Take 1, 2 or 3 matchsticks from the pile

  Examples:

    iex> NimGame.Core.Matchsticks.take_matchsticks(%NimGame.Core.Matchsticks{matchsticks: 13}, 1)
    %NimGame.Core.Matchsticks{matchsticks: 12}

    iex> NimGame.Core.Matchsticks.take_matchsticks(%NimGame.Core.Matchsticks{matchsticks: 13}, 2)
    %NimGame.Core.Matchsticks{matchsticks: 11}

    iex> NimGame.Core.Matchsticks.take_matchsticks(%NimGame.Core.Matchsticks{matchsticks: 13}, 3)
    %NimGame.Core.Matchsticks{matchsticks: 10}

    iex> NimGame.Core.Matchsticks.take_matchsticks(%NimGame.Core.Matchsticks{matchsticks: 13}, 0)
    {:error, :invalid_number_of_matchsticks}

    iex> NimGame.Core.Matchsticks.take_matchsticks(%NimGame.Core.Matchsticks{matchsticks: 13}, 4)
    {:error, :invalid_number_of_matchsticks}

    iex> NimGame.Core.Matchsticks.take_matchsticks(%NimGame.Core.Matchsticks{matchsticks: 1}, 2)
    {:error, :not_enough_matchsticks}
  """
  @spec take_matchsticks(t(), pos_integer()) :: t() | {:error, atom()}
  def take_matchsticks(matchsticks, amount)

  def take_matchsticks(%{matchsticks: matchsticks_remaining}, amount)
      when amount > matchsticks_remaining,
      do: {:error, :not_enough_matchsticks}

  def take_matchsticks(%{matchsticks: _matchsticks_remaining}, amount)
      when amount <= 0 or amount > 3,
      do: {:error, :invalid_number_of_matchsticks}

  def take_matchsticks(%{matchsticks: matchsticks_remaining}, amount)
      when amount > 0 and amount <= 3,
      do: %__MODULE__{matchsticks: matchsticks_remaining - amount}
end
