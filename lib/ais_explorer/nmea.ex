defmodule AisExplorer.Nmea do
  @moduledoc """
  The Nmea context.
  """

  import Ecto.Query, warn: false
  alias AisExplorer.Repo

  alias AisExplorer.Nmea.NmeaPosition

  @doc """
  Returns the list of nmea_positions.

  ## Examples

      iex> list_nmea_positions()
      [%NmeaPosition{}, ...]

  """
  def list_nmea_positions do
    Repo.all(NmeaPosition)
  end

  @doc """
  Gets a single nmea_position.

  Raises `Ecto.NoResultsError` if the Nmea event does not exist.

  ## Examples

      iex> get_nmea_position!(123)
      %NmeaPosition{}

      iex> get_nmea_position!(456)
      ** (Ecto.NoResultsError)

  """
  def get_nmea_position!(id), do: Repo.get!(NmeaPosition, id)

  @doc """
  Creates a nmea_position.

  ## Examples

      iex> create_nmea_position(%{field: value})
      {:ok, %NmeaPosition{}}

      iex> create_nmea_position(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_nmea_position(attrs \\ %{}) do
    %NmeaPosition{}
    |> NmeaPosition.changeset(attrs)
    |> Repo.insert()
  end
end
