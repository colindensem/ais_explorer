defmodule AisExplorer.Repo.Migrations.CreateNmeaPositions do
  use Ecto.Migration

  def change do
    create table(:nmea_positions) do
      add :mmsi, :integer, null: false
      add :timestamp, :naive_datetime, null: false
      add :latitude, :float
      add :longitude, :float
      add :speed_over_ground, :float
      add :course_over_ground, :float
      add :heading, :float
      add :vessel_name, :string
      add :imo, :string
      add :call_sign, :string
      add :vessel_type, :integer, default: 0
      add :status, :integer
      add :length, :integer, default: 0
      add :width, :integer, default: 0
      add :draft, :float, default: 0.0
      add :cargo, :integer, default: 0
      add :transceiver_class, :string
    end

    create index(:nmea_positions, [:mmsi])
    create index(:nmea_positions, [:imo])
    create index(:nmea_positions, [:vessel_name])
    create index(:nmea_positions, [:call_sign])
  end
end
