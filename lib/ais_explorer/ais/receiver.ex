defmodule AisExplorer.Ais.Receiver do
  @moduledoc """
  This module is responsible for receiving `NMEA` style messages from a UDP server.

  It's behaviour can be configured in the `config/config.exs` file.
  """
  alias AisExplorer.Nmea.ParsedPosition
  alias AisExplorer.Nmea.Writer
  use GenServer

  require Logger

  @config Application.compile_env(:ais_explorer, AisExplorer.Ais.Receiver)

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, {}, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, socket} = :gen_udp.open(udp_port(), [:binary, {:active, true}])
    {:ok, socket}
  end

  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    # Our data feed only has one type of message, from one source.
    # More sources or message types would add complexity here with a pattern match on the message type.
    case ParsedPosition.parse(data) do
      %AisExplorer.Nmea.ParsedPosition{mmsi: mmsi} = parsed_position when mmsi != 0 ->
        Writer.insert(parsed_position)

      %AisExplorer.Nmea.ParsedPosition{} = parsed_position ->
        Logger.error("Invalid MMSI: #{parsed_position}")

      {:error, reason} ->
        Logger.error("Failed to parse data: #{reason}")
    end

    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}

  defp udp_port, do: @config[:udp_port]
end
