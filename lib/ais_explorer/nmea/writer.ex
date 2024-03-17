defmodule AisExplorer.Nmea.Writer do
  @moduledoc """
  This module is responsible for writing NMEA data in batches to the database.
  """
  use GenServer
  require Logger

  alias AisExplorer.Nmea.NmeaPosition
  alias AisExplorer.Repo

  @config Application.compile_env(:ais_explorer, AisExplorer.Nmea.Writer)

  # Client APIs

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def insert(event) do
    GenServer.cast(__MODULE__, {:insert, event})

    {:ok, event}
  end

  def flush() do
    GenServer.call(__MODULE__, :flush, :infinity)

    :ok
  end

  # Server (callbacks)

  @impl true
  def init(buffer) do
    Process.flag(:trap_exit, true)
    timer = Process.send_after(self(), :tick, flush_interval_ms())

    {:ok, %{buffer: buffer, timer: timer}}
  end

  @impl true
  def handle_cast({:insert, event}, %{buffer: buffer, timer: timer} = state) do
    new_buffer = [event | buffer]

    if length(new_buffer) >= max_buffer_size() do
      Logger.info("Buffer full, flushing to storage #{DateTime.utc_now()}")
      Process.cancel_timer(timer)
      do_flush(new_buffer)
      new_timer = Process.send_after(self(), :tick, flush_interval_ms())

      {:noreply, %{buffer: [], timer: new_timer}}
    else
      {:noreply, %{state | buffer: new_buffer}}
    end
  end

  @impl true
  def handle_info(:tick, %{buffer: buffer} = _state) do
    do_flush(buffer)
    timer = Process.send_after(self(), :tick, flush_interval_ms())

    {:noreply, %{buffer: [], timer: timer}}
  end

  @impl true
  def handle_info({:EXIT, _pid, error_struct}, %{buffer: buffer} = _state) do
    case error_struct do
      {%DBConnection.ConnectionError{}} ->
        Logger.error("Database task failed. Trying flush event buffer again...")
        :timer.sleep(1)
        do_flush(buffer)

      error ->
        Logger.error("Database task failed: #{inspect(error)}")
    end

    after_database_task_completion()
  end

  @impl true
  def handle_call(:flush, _from, %{buffer: buffer, timer: timer} = _state) do
    Process.cancel_timer(timer)
    do_flush(buffer)
    new_timer = Process.send_after(self(), :tick, flush_interval_ms())

    {:reply, nil, %{buffer: [], timer: new_timer}}
  end

  @impl true
  def terminate(_reason, %{buffer: buffer} = _state) do
    Logger.info("Flushing event buffer before shutdown...")
    do_flush(buffer)
  end

  # Private/utility methods

  defp after_database_task_completion do
    timer = Process.send_after(self(), :tick, flush_interval_ms())
    {:noreply, %{buffer: [], timer: timer}}
  end

  defp do_flush([]), do: nil

  defp do_flush(buffer) do
    # TODO potentially offload this to a task
    Logger.info("Flushing #{length(buffer)} events.")

    events =
      buffer
      |> Enum.map(&Map.from_struct/1)

    Repo.insert_all(NmeaPosition, events)
  end

  defp flush_interval_ms, do: @config[:flush_interval_ms]
  defp max_buffer_size, do: @config[:max_buffer_size]
end
