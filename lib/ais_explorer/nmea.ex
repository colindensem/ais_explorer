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

  @doc """
  Returns the list of nmea_positions for a given mssi reference

  ## Examples

      iex> search_by_mmsi(mmsi)
      [%NmeaPosition{}, ...]

  """
  def search_by_mmsi(mmsi) do
    query =
      from np in NmeaPosition,
        where: np.mmsi == ^mmsi,
        order_by: [asc: np.timestamp]

    Repo.all(query)
  end

  @doc """
  Returns the list of nmea_positions for a given vessel name

  ## Examples

      iex> search_by_vessel_name("GloRIA")
      [%NmeaPosition{}, ...]

  """
  def search_by_vessel_name(search_term) do
    query =
      from np in NmeaPosition,
        where: ilike(np.vessel_name, ^"#{search_term}%"),
        order_by: [asc: np.timestamp]

    Repo.all(query)
  end
end
