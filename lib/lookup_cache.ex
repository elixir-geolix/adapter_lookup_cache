defmodule Geolix.Adapter.LookupCache do
  @moduledoc """
  Lookup cache adapter for Geolix

  ## Adapter Configuration

      config :geolix,
        databases: [
          %{
            id: :my_mmdb_database,
            adapter: Geolix.Adapter.LookupCache,
            lookup: %{
              adapter: Geolix.Adapter.Fake,
              data:
                %{}
                |> Map.put({1, 1, 1, 1}, %{country: %{iso_code: "US"}})
                |> Map.put({2, 2, 2, 2}, %{country: %{iso_code: "GB"}})
              }
            }
          }
        ]
  """

  @behaviour Geolix.Adapter

  @impl Geolix.Adapter
  def database_workers(%{id: database_id, lookup: %{adapter: adapter} = database}) do
    Code.ensure_loaded(adapter)

    if function_exported?(adapter, :database_workers, 1) do
      database
      |> Map.put(:id, database_id)
      |> adapter.database_workers()
    else
      []
    end
  end

  @impl Geolix.Adapter
  def load_database(%{id: database_id, lookup: %{adapter: adapter} = database}) do
    if Code.ensure_loaded(adapter) do
      if function_exported?(adapter, :load_database, 1) do
        database
        |> Map.put(:id, database_id)
        |> adapter.load_database()
      else
        :ok
      end
    else
      {:error, {:config, :unknown_adapter}}
    end
  end

  @impl Geolix.Adapter
  def lookup(ip, opts, %{id: database_id, lookup: %{adapter: adapter} = database}) do
    database = Map.put(database, :id, database_id)

    adapter.lookup(ip, opts, database)
  end

  @impl Geolix.Adapter
  def unload_database(%{id: database_id, lookup: %{adapter: adapter} = database}) do
    if function_exported?(adapter, :unload_database, 1) do
      database
      |> Map.put(:id, database_id)
      |> adapter.unload_database()
    else
      :ok
    end
  end
end
