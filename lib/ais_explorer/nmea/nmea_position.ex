defmodule AisExplorer.Nmea.NmeaPosition do
  @moduledoc """
  The NmeaPosition schema. Contains NMEA data for vessel position updates.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields ~w(mmsi timestamp)a
  @optional_fields ~w(latitude longitude vessel_name imo call_sign status speed_over_ground course_over_ground heading vessel_type length width draft cargo transceiver_class)a

  @doc """
  Required fields: #{inspect(@required_fields)}
  Optional fields: #{inspect(@optional_fields)}
  """
  schema "nmea_positions" do
    field :call_sign, :string
    field :cargo, :integer
    field :course_over_ground, :float
    field :draft, :float
    field :heading, :float
    field :imo, :string
    field :latitude, :float
    field :length, :integer
    field :longitude, :float
    field :mmsi, :integer
    field :speed_over_ground, :float
    field :status, :integer
    field :timestamp, :naive_datetime
    field :transceiver_class, :string
    field :vessel_name, :string
    field :vessel_type, :integer
    field :width, :integer
  end

  @doc false
  def changeset(%__MODULE__{} = nmea_position, attrs) do
    nmea_position
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
