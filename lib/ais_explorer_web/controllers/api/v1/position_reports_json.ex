defmodule AisExplorerWeb.Api.V1.PositionReportsJSON do
  alias AisExplorer.Nmea.NmeaPosition

  @doc """
  Renders a list of positions.
  """
  def index(%{positions: positions}) do
    %{data: for(pos <- positions, do: data(pos))}
  end

  defp data(%NmeaPosition{} = nmea) do
    %{
      id: nmea.id,
      call_sign: nmea.call_sign,
      cargo: nmea.cargo,
      course_over_ground: nmea.course_over_ground,
      draft: nmea.draft,
      heading: nmea.heading,
      imo: nmea.imo,
      latitude: nmea.latitude,
      length: nmea.length,
      longitude: nmea.longitude,
      mmsi: nmea.mmsi,
      speed_over_ground: nmea.speed_over_ground,
      status: nmea.status,
      timestamp: nmea.timestamp,
      transceiver_class: nmea.transceiver_class,
      vessel_name: nmea.vessel_name,
      vessel_type: nmea.vessel_type,
      width: nmea.width
    }
  end
end
