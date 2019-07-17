defmodule Geolix.Adapter.LookupCache do
  @moduledoc """
  Lookup cache adapter for Geolix

  ## Adapter Configuration

      config :geolix,
        databases: [
          %{
            id: :my_mmdb_database,
            adapter: Geolix.Adapter.LookupCache,
            cache: %{
              adapter: MyCustomCacheAdapter
            },
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
  def database_workers(%{
        id: database_id,
        cache: %{adapter: cache_adapter} = cache,
        lookup: %{adapter: database_adapter} = database
      }) do
    cache_workers =
      if Code.ensure_loaded?(cache_adapter) and
           function_exported?(cache_adapter, :cache_workers, 2) do
        database
        |> Map.put(:id, database_id)
        |> cache_adapter.cache_workers(cache)
      else
        []
      end

    database_workers =
      if Code.ensure_loaded?(database_adapter) and
           function_exported?(database_adapter, :database_workers, 1) do
        database
        |> Map.put(:id, database_id)
        |> database_adapter.database_workers()
      else
        []
      end

    cache_workers ++ database_workers
  end

  @impl Geolix.Adapter
  def load_database(%{
        id: database_id,
        cache: %{adapter: cache_adapter} = cache,
        lookup: %{adapter: database_adapter} = database
      }) do
    if Code.ensure_loaded?(cache_adapter) and function_exported?(cache_adapter, :load_cache, 2) do
      :ok = cache_adapter.load_cache(database, cache)
    end

    if Code.ensure_loaded?(database_adapter) do
      if function_exported?(database_adapter, :load_database, 1) do
        database
        |> Map.put(:id, database_id)
        |> database_adapter.load_database()
      else
        :ok
      end
    else
      {:error, {:config, :unknown_adapter}}
    end
  end

  @impl Geolix.Adapter
  def lookup(ip, opts, %{
        id: database_id,
        cache: %{adapter: cache_adapter} = cache,
        lookup: %{adapter: database_adapter} = database
      }) do
    database = Map.put(database, :id, database_id)

    case cache_adapter.get(ip, opts, database, cache) do
      {:ok, result} when is_map(result) ->
        result

      {:ok, nil} ->
        result = database_adapter.lookup(ip, opts, database)
        :ok = cache_adapter.put(ip, opts, database, cache, result)

        result

      {:error, _} ->
        database_adapter.lookup(ip, opts, database)
    end
  end

  @impl Geolix.Adapter
  def unload_database(%{
        id: database_id,
        cache: %{adapter: cache_adapter} = cache,
        lookup: %{adapter: database_adapter} = database
      }) do
    if Code.ensure_loaded?(cache_adapter) and function_exported?(cache_adapter, :unload_cache, 2) do
      :ok = cache_adapter.unload_cache(database, cache)
    end

    if function_exported?(database_adapter, :unload_database, 1) do
      database
      |> Map.put(:id, database_id)
      |> database_adapter.unload_database()
    else
      :ok
    end
  end
end
