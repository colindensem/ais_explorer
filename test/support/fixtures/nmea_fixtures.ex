defmodule AisExplorer.NmeaFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AisExplorer.Nmea` context.
  """

  @doc """
  Generate a nmea_position.
  """
  def nmea_position_fixture(attrs \\ %{}) do
    {:ok, nmea_position} =
      attrs
      |> Enum.into(%{
        call_sign: "WDI7890",
        cargo: 52,
        course_over_ground: 360.0,
        draft: 2.3,
        heading: 511.0,
        imo: "IMO100637903",
        latitude: 38.42409,
        length: 16,
        longitude: -82.59932,
        mmsi: 367_733_230,
        speed_over_ground: 0.3,
        status: 9,
        timestamp: ~N[2023-03-16T00:00:01],
        transceiver_class: "A",
        vessel_name: "EDITH TEST",
        vessel_type: 52,
        width: 7
      })
      |> AisExplorer.Nmea.create_nmea_position()

    nmea_position
  end
end
