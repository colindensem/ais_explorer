defmodule AisExplorer.NmeaTest do
  use AisExplorer.DataCase

  alias AisExplorer.Nmea

  describe "nmea_positions" do
    alias AisExplorer.Nmea.NmeaPosition

    import AisExplorer.NmeaFixtures

    @invalid_attrs %{
      call_sign: nil,
      cargo: nil,
      course_over_ground: nil,
      draft: nil,
      heading: nil,
      imo: nil,
      latitude: nil,
      length: nil,
      longitude: nil,
      mmsi: nil,
      speed_over_ground: nil,
      status: nil,
      timestamp: nil,
      transceiver_class: nil,
      vessel_name: nil,
      vessel_type: nil,
      width: nil
    }

    test "list_nmea_positions/0 returns all nmea_positions" do
      nmea_position = nmea_position_fixture()
      assert Nmea.list_nmea_positions() == [nmea_position]
    end

    test "search_by_mmsi/1 returns all nmea_positions with given mmsi" do
      _nmea_position_1 = nmea_position_fixture()
      nmea_position_2 = nmea_position_fixture(mmsi: 367_176_310)
      assert Nmea.search_by_mmsi(nmea_position_2.mmsi) == [nmea_position_2]
    end

    test "search_by_vessel_name/1 returns all nmea_positions for a given vessel name" do
      _nmea_position_1 = nmea_position_fixture()
      nmea_position_2 = nmea_position_fixture(vessel_name: "GLORIA")
      assert Nmea.search_by_vessel_name("GlorIA") == [nmea_position_2]
    end

    test "search_by_vessel_name/1 returns all nmea_positions for partial vessel name" do
      nmea_position_1 = nmea_position_fixture(vessel_name: "GLORY")
      nmea_position_2 = nmea_position_fixture(vessel_name: "GLORIA")
      assert Nmea.search_by_vessel_name("GloR") == [nmea_position_1, nmea_position_2]
    end

    test "get_nmea_position!/1 returns the nmea_position with given id" do
      nmea_position = nmea_position_fixture()
      assert Nmea.get_nmea_position!(nmea_position.id) == nmea_position
    end

    test "create_nmea_position/1 with valid data creates a nmea_position" do
      valid_attrs = %{
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
      }

      assert {:ok, %NmeaPosition{} = nmea_position} = Nmea.create_nmea_position(valid_attrs)
      assert nmea_position.call_sign == "WDI7890"
      assert nmea_position.cargo == 52
      assert nmea_position.course_over_ground == 360.0
      assert nmea_position.draft == 2.3
      assert nmea_position.heading == 511.0
      assert nmea_position.imo == "IMO100637903"
      assert nmea_position.latitude == 38.42409
      assert nmea_position.length == 16
      assert nmea_position.longitude == -82.59932
      assert nmea_position.mmsi == 367_733_230
      assert nmea_position.speed_over_ground == 0.3
      assert nmea_position.status == 9
      assert nmea_position.timestamp == ~N[2023-03-16T00:00:01]
      assert nmea_position.transceiver_class == "A"
      assert nmea_position.vessel_name == "EDITH TEST"
      assert nmea_position.vessel_type == 52
      assert nmea_position.width == 7
    end

    test "create_nmea_position/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Nmea.create_nmea_position(@invalid_attrs)
    end
  end
end
