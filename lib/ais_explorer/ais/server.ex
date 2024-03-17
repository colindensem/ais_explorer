defmodule AisExplorer.Ais.Server do
  @moduledoc """
  This module is responsible for running a UDP server to emulate message broadcasts.

  It's behaviour can be configured in the `config/config.exs` file.

  Each message is transmitted as a string, headers are not sent:

  `
  MMSI,BaseDateTime,LAT,LON,SOG,COG,Heading,VesselName,IMO,CallSign,VesselType,Status,Length,Width,Draft,Cargo,TransceiverClass
  367733230,2023-03-16T00:00:01,38.42409,-82.59932,0.3,360.0,511.0,EDITH,IMO100637903,WDI7890,52,9,16,7,2.3,52,A
  `


  """
  use GenServer
  require Logger

  @config Application.compile_env(:ais_explorer, AisExplorer.Ais.Server)

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, socket} = :gen_udp.open(0, [:binary, {:active, false}])

    messages =
      file_path()
      |> File.read!()
      |> String.split("\n")

    start_transmission_loop(socket, messages)

    {:ok, {socket, messages}}
  end

  def handle_cast(:stop, state) do
    Logger.info("UDP Server terminated.")
    {:stop, :normal, state}
  end

  def handle_info(:stop, state) do
    {:stop, :normal, state}
  end

  defp start_transmission_loop(socket, messages) do
    Task.start(fn ->
      loop_transmission(socket, messages)
    end)
  end

  defp loop_transmission(socket, messages) do
    # A purposely slow start/delay to allow the server to start up
    :timer.sleep(transmit_delay())

    Logger.info("File transmission starting. #{length(messages)} messages to send.")

    Enum.each(messages, fn message ->
      transmit_message(socket, message)
      :timer.sleep(transmit_interval())
    end)

    Logger.info("File transmission complete.")
    # Send a stop message to the GenServer itself to initiate termination
    GenServer.cast(self(), :stop)
  end

  defp transmit_message(socket, message) do
    destination = {broadcast_ip(), broadcast_port()}

    :gen_udp.send(socket, destination, message)
  rescue
    _ -> Logger.error("Error transmitting message: #{inspect(message)}")
  end

  defp file_path, do: @config[:file_path]
  defp broadcast_ip, do: @config[:broadcast_ip]
  defp broadcast_port, do: @config[:broadcast_port]
  defp transmit_delay, do: @config[:transmit_delay]
  defp max_transmit_rate, do: @config[:max_transmit_rate]

  defp transmit_interval(), do: round(1000 / max_transmit_rate())
end
