defmodule AisExplorer.Repo do
  use Ecto.Repo,
    otp_app: :ais_explorer,
    adapter: Ecto.Adapters.Postgres
end
