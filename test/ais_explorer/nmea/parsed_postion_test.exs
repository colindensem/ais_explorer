defmodule AisExplorer.Nmea.ParsedPositionTest do
  use ExUnit.Case
  alias AisExplorer.Nmea.ParsedPosition

  test "parsing valid line" do
    line =
      "123456789,2024-03-16T12:34:56,51.5074,-0.1278,10.5,180.0,90.0,Ship1,IMO12345,ABCD,1,2,100,20,5.5,9,A"

    expected_result = %AisExplorer.Nmea.ParsedPosition{
      call_sign: "ABCD",
      cargo: 9,
      course_over_ground: 180.0,
      draft: 5.5,
      heading: 90.0,
      imo: "IMO12345",
      latitude: 51.5074,
      length: 100,
      longitude: -0.1278,
      mmsi: 123_456_789,
      speed_over_ground: 10.5,
      status: 2,
      timestamp: ~N[2024-03-16 12:34:56],
      transceiver_class: "A",
      vessel_name: "Ship1",
      vessel_type: 1,
      width: 20
    }

    assert ParsedPosition.parse(line) == expected_result
  end

  test "parsing invalid line" do
    line = "invalid line"

    assert ParsedPosition.parse(line) ==
             {:error, "Invalid NMEA sentence format: \"invalid line\""}
  end

  test "parsing line with missing values" do
    line = "123456789,2024-03-16T12:34:57,,,,,90.0,Ship1,IMO12345,ABCD,1,9,,,,0,A"

    expected_result = %AisExplorer.Nmea.ParsedPosition{
      call_sign: "ABCD",
      cargo: 0,
      course_over_ground: 0.0,
      draft: 0.0,
      heading: 90.0,
      imo: "IMO12345",
      latitude: 0.0,
      length: 0,
      longitude: 0.0,
      mmsi: 123_456_789,
      speed_over_ground: 0.0,
      status: 9,
      timestamp: ~N[2024-03-16 12:34:57],
      transceiver_class: "A",
      vessel_name: "Ship1",
      vessel_type: 1,
      width: 0
    }

    assert ParsedPosition.parse(line) == expected_result
  end
end
