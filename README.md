# AIS Explorer

A exploratory project using Elixir, Phoenix & Postgres to process and report on NMEA sentences.

AIS data is supplied as a UDP stream of data in the form of NMEA sentences. Worldwide satellite feed volumes can be as high as 100-200k messages per second.

Decoded messages contain a position report comprising vessel ID, timestamp and geospatial position. Messages do not necessarily arrive in strict time order. Individual vessels update their position reports every 5-10 seconds.

## Table of Contents

- [AIS Explorer](#ais-explorer)
  - [Table of Contents](#table-of-contents)
  - [Test Data](#test-data)
  - [Architecture Overview](#architecture-overview)
  - [Configuration](#configuration)
  - [Running the demo](#running-the-demo)
    - [API Examples](#api-examples)
  - [Development](#development)
  - [Caveats](#caveats)
  - [Summary](#summary)

## Test Data

AIS/NMEA data is generally protected. There however exists a few sources of historical data and live TCP feeds. Notably these two services were considered for this exploration:

- [The Norwegian AIS network has an open and a closed component. Data is accessed in both cases via a standard internet connection.](https://kystverket.no/en/navigation-and-monitoring/ais/access-to-ais-data/)
- [Bureau of Ocean Energy Management (BOEM) and National Oceanic and Atmospheric Administration (NOAA)](https://marinecadastre.gov/AIS/)

The Norwegian service is a live TCP feed of AIS data with `BSVDM` message types from Norwegian waters. Initial investigations on how to actually parse an AIS message led to a couple of interesting libraries and possible approaches.

```
!BSVDM,1,1,,B,B3m=P1P008A4BuakqIsJwwa5oP06,0*30
```

There is an erlang library for decoding AIS messages, [aisle](https://github.com/pentlandedge/aisle). However this does not handle `BSVDM` messages. alternatives in Rust([ais](https://github.com/squidpickles/ais/)) and Python([pyais](https://github.com/M0r13n/pyais/tree/master)) were considered. Both of these languages can be run from Elixir as a [NIF](https://www.erlang.org/doc/tutorial/nif.html), although there are some drawbacks.

The Marine Cadastre dataset was selected as a batch of decoded AIS messages in a CSV format. These messages are already decoded and stored in a downloadable CSV file. The initial module is to provide a simple UDP server that reads the data file and serves the data messages. However they only represent a partial view of one message type; ship position updates.

Example CSV data that will be broadcast over UDP

```csv
MMSI,BaseDateTime,LAT,LON,SOG,COG,Heading,VesselName,IMO,CallSign,VesselType,Status,Length,Width,Draft,Cargo,TransceiverClass
367733230,2023-03-16T00:00:01,38.42409,-82.59932,0.3,360.0,511.0,EDITH,IMO100637903,WDI7890,52,9,16,7,2.3,52,A
367409260,2023-03-16T00:00:01,41.47232,-81.66902,2.7,350.2,173.0,DOROTHY ANN,IMO8955732,WDE8761,31,0,37,13,6.2,57,A
```

## Architecture Overview

A series of steps(modules) will be used to serve messages, receive, parse and write to a data store.

_Note: We're purposefully skipping the AIS decode stage with the decoded sample data we're using._

- AisExplorer.Ais.Server - A UDP server module, loads a file and serves messages over UDP
- AisExplorer.Ais.Receiver - A GenServer to receive UDP messages and handle the initial ingesting
- AisExplorer.Nmea.Parser - A parser for the data message to convert raw data into a storable standard
- AisExplorer.Nmea.Writer - A GenServer to batch messages into writes to the data store.

## Configuration

The application has a few configuration choices, these can be reviewed in `config.exs`.

- `config :ais_explorer, AisExplorer.Ais.Server` - The UDP server config
- `config :ais_explorer, AisExplorer.Ais.Receiver` - The UDP receiver config
- `config :ais_explorer, AisExplorer.Nmea.Writer` - The write buffer config

## Running the demo

From a terminal shell, run `iex -S mix phx.server`. This will load the application, shortly afterwards(depends on config) you will see log info from the server and writer.

```
[info] File transmission starting. 1000000 messages to send.
[info] Buffer full, flushing to storage 2024-03-17 18:30:47.276717Z
[info] Flushing 3000 events.
[info] Buffer full, flushing to storage 2024-03-17 18:30:48.030055Z
[info] Flushing 3000 events.
[info] Buffer full, flushing to storage 2024-03-17 18:30:48.424029Z
[info] Flushing 3000 events.
[info] Buffer full, flushing to storage 2024-03-17 18:30:48.797167Z
[info] Flushing 3000 events.
```

You can query the API at the following endpoints:

- by Vesel Name
- by MMSI id

### API Examples

There is no pagination/offsets on this version of the api.

```bash
 curl --request GET \
  --url 'http://localhost:4000/api/v1/position_reports?vessel_name=GEORGIA' \
  --header 'content-type: application/json'
```

```bash
 curl --request GET \
--url 'http://localhost:4000/api/v1/position_reports?mmsi=367619920' \
--header 'content-type: application/json'
```

_Note: Each restart will rerun the server, receiver and writing, thus the record count will increase significantly._

## Development

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Caveats

During the development of the writer module, we encountered several notable limitations. Firstly, PostgreSQL imposes a parameter limit on statements, which directly affects the size of the batches we can insert. Batches larger than 3000 risk failure to insert records. Additionally, our fixed batch size of 3000 limits the number of rows processed per slow database operation, inevitably slowing down the ingestion rate. One potential solution could involve storing messages as BJSON in PostgreSQL, which would reduce parameters at the expense of indexing and searching capabilities. Another strategy could involve extracting key search fields to optimize query performance, though this might not be viable for all scenarios.

To address these issues, one approach is to initiate a new Task for each flush operation to run asynchronously. However, this method rapidly exhausts the database connection pool, resulting in the loss of most records due to failed tasks. Task management and retry mechanisms could potentially mitigate this, but in a continuous feed environment, retries may eventually create a backlog.

In concept, increasing resources, such as employing a larger database server pool, could alleviate some of these challenges. Alternatively, leveraging Mnesia to initially store messages and then using workers to process them into PostgreSQL could offer a solution. This approach could also support additional operations like smoothing, anomaly detection, or other processing needs.

One significant limitation of the GenServer approach lies in its throughput. GenServers are inherently single-threaded, meaning they process messages one at a time. In high-throughput scenarios, this can lead to bottlenecks and reduced performance.

In high-throughput situations where the limitations of a GenServer become apparent, an alternative approach is to use a task-based concurrency model with a supervised Task.Supervisor. This allows for concurrent execution of tasks, distributing the workload across multiple processes and potentially improving overall throughput.

Using Task.Supervisor, tasks can be spawned to handle individual requests or units of work. These tasks can run concurrently, processing messages or performing operations in parallel. This approach can better utilize available system resources and improve scalability compared to the single-threaded nature of GenServers.

Additionally, for even higher throughput and more fine-grained control over concurrency, leveraging lightweight processes with the help of libraries like Flow or Broadway could be beneficial. These libraries enable data processing pipelines and parallel execution of tasks across multiple CPU cores, further optimizing performance in high-throughput scenarios.

Ultimately, the choice of concurrency model depends on the specific requirements of the application, the expected workload, and the desired level of scalability and performance.

## Summary

Looking back, while the Task-based concurrency model presents a step forward in managing high-throughput scenarios compared to GenServers, it's clear that there are other avenues worth exploring to further optimize performance and address potential scalability hurdles.

One intriguing alternative is delving into message queuing systems like Kafka or RabbitMQ. Although I haven't had direct experience with these tools, they're known for their ability to handle large volumes of messages efficiently. Offloading message processing to dedicated message brokers could lead to improved throughput and better management of workload spikes.

Another avenue of interest is investigating lightweight concurrency models offered by libraries like Flow or Broadway. These tools facilitate the creation of data processing pipelines and support parallel task execution across multiple CPU cores. While I haven't had hands-on experience with them, they seem promising in maximizing resource utilization and enhancing overall performance in high-throughput scenarios. The database write remains the bottleneck.

Thus, selecting a performant data store optimized for write-heavy workloads could significantly impact system performance. Although I'm not directly familiar with technologies like TimescaleDB or Apache Cassandra, they're reputed for their capabilities in efficiently handling large volumes of writes. Choosing the right data store architecture tailored to the application's needs could ensure data persistence and scalability without compromising performance.

To sum up, while the Task-based concurrency model offers an initial improvement in throughput, exploring alternatives such as message queuing systems, lightweight concurrency libraries, and performant data stores could unlock additional scalability and performance benefits. It's an exciting journey of discovery for anyone keen on optimizing system performance in high-throughput scenarios.
