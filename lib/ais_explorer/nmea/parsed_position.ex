defmodule AisExplorer.Nmea.ParsedPosition do
  @moduledoc """
  This module is responsible for parsing NMEA string sentence into a useable struct.

  The NMEA holds values for fields like `status` as an integer. However we're not mapping those values to lookup/enumerable values in this demo.
  """

  @enforce_keys [:mmsi, :timestamp]

  defstruct [
    :call_sign,
    :cargo,
    :course_over_ground,
    :draft,
    :heading,
    :imo,
    :latitude,
    :length,
    :longitude,
    :mmsi,
    :speed_over_ground,
    :status,
    :timestamp,
    :transceiver_class,
    :vessel_name,
    :vessel_type,
    :width
  ]

  @type t :: %__MODULE__{
          call_sign: String.t(),
          cargo: integer(),
          course_over_ground: float(),
          draft: float(),
          heading: float(),
          imo: String.t(),
          latitude: float(),
          length: integer(),
          longitude: float(),
          mmsi: integer(),
          speed_over_ground: float(),
          status: integer(),
          timestamp: NaiveDateTime.t(),
          transceiver_class: String.t(),
          vessel_name: String.t(),
          vessel_type: integer(),
          width: integer()
        }

  def parse(line) when is_binary(line) do
    cleaned_line =
      line
      |> String.replace("/r", "")
      |> String.trim()
      |> String.split(",", parts: 17)

    case cleaned_line do
      [
        mmsi_str,
        base_date_time,
        lat_str,
        lon_str,
        sog_str,
        cog_str,
        heading_str,
        vessel_name,
        imo,
        call_sign,
        vessel_type,
        status,
        length_str,
        width_str,
        draft_str,
        cargo,
        transceiver_class
      ] ->
        %__MODULE__{
          call_sign: call_sign,
          cargo: parse_integer(cargo),
          course_over_ground: parse_float(cog_str),
          draft: parse_float(draft_str),
          heading: parse_float(heading_str),
          imo: imo,
          latitude: parse_float(lat_str),
          length: parse_integer(length_str),
          longitude: parse_float(lon_str),
          mmsi: parse_integer(mmsi_str),
          speed_over_ground: parse_float(sog_str),
          status: parse_integer(status),
          timestamp: parse_datetime(base_date_time),
          transceiver_class: transceiver_class,
          vessel_name: vessel_name,
          vessel_type: parse_integer(vessel_type),
          width: parse_integer(width_str)
        }

      _ ->
        {:error, "Invalid NMEA sentence format: #{inspect(line)}"}
    end
  end

  def parse_line(_), do: {:error, "Invalid line"}

  defp parse_datetime(value) do
    case NaiveDateTime.from_iso8601(value) do
      {:ok, datetime} -> datetime
      :error -> NaiveDateTime.utc_now()
    end
  end

  defp parse_float(value) when value == "", do: 0.0
  defp parse_float(value), do: String.to_float(value)

  defp parse_integer(value) when value == "", do: 0
  defp parse_integer(value), do: String.to_integer(value)
end
