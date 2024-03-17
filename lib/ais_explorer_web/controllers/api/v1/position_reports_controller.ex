defmodule AisExplorerWeb.Api.V1.PositionReportsController do
  use AisExplorerWeb, :controller
  alias AisExplorer.Nmea

  def index(conn, %{"mmsi" => mmsi}) do
    positions = Nmea.search_by_mmsi(mmsi)
    render(conn, :index, positions: positions)
  end

  def index(conn, %{"vessel_name" => vessel_name}) do
    positions = Nmea.search_by_vessel_name(vessel_name)
    render(conn, :index, positions: positions)
  end
end
