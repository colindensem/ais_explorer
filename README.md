# AIS Explorer

A exploratory project using Elixir, Phoenix & Postgres to process and report on NMEA sentences.

AIS data is supplied as a UDP stream of data in the form of NMEA sentences. Worldwide satellite feed volumes can be as high as 100-200k messages per second.

Decoded messages contain a position report comprising vessel ID, timestamp and geospatial position. Messages do not necessarily arrive in strict time order. Individual vessels update their position reports every 5-10 seconds.

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
- AisExplorer.Nmea.Parser - A parser for the data message to convert raw data into a storable standard

## Configuration

The application has a few configuration choices, these can be reviewed in `config.exs`.

- `config :ais_explorer, AisExplorer.Ais.Server` - The UDP server config

## Running the demo

To Follow

## Development

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix
