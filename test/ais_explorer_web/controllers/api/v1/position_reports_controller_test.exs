defmodule AisExplorerWeb.Api.V1.PositionReportsControllerTest do
  use AisExplorerWeb.ConnCase
  import AisExplorer.NmeaFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "index returns positions for given mmsi", %{conn: conn} do
      position_1 = nmea_position_fixture(mmsi: 123, timestamp: ~N[2023-03-16T00:00:02])
      _position_2 = nmea_position_fixture(mmsi: 1234)
      position_3 = nmea_position_fixture(mmsi: 123, timestamp: ~N[2023-03-16T00:00:01])

      conn = get(conn, ~p"/api/v1/position_reports?mmsi=123")

      [result_1, result_2] = json_response(conn, 200)["data"]
      assert result_1["id"] == position_3.id
      assert result_2["id"] == position_1.id
    end

    test "index returns positions for vessel name search", %{conn: conn} do
      position_1 =
        nmea_position_fixture(
          vessel_name: "JOHN",
          mmsi: 123,
          timestamp: ~N[2023-03-16T00:00:03]
        )

      _position_2 =
        nmea_position_fixture(
          vessel_name: "MSI JOHN",
          mmsi: 1234,
          timestamp: ~N[2023-03-16T00:00:03]
        )

      position_3 =
        nmea_position_fixture(
          vessel_name: "JOHN",
          mmsi: 123,
          timestamp: ~N[2023-03-16T00:00:02]
        )

      position_4 =
        nmea_position_fixture(
          vessel_name: "JOHN PAUL",
          mmsi: 1235,
          timestamp: ~N[2023-03-16T00:00:01]
        )

      conn = get(conn, ~p"/api/v1/position_reports?vessel_name=jOhN")

      [result_1, result_2, result_3] = json_response(conn, 200)["data"]
      assert result_1["id"] == position_4.id
      assert result_2["id"] == position_3.id
      assert result_3["id"] == position_1.id
    end
  end
end
