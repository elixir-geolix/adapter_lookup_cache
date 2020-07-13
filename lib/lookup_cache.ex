defmodule Geolix.Adapter.LookupCache do
  @moduledoc """
  Lookup cache adapter for Geolix.

  ## Adapter Configuration

  To start using the adapter in front of a regular adapter you need to modify
  the database entry of your `:geolix` configuration:

      config :geolix,
        databases: [
          %{
            id: :my_lookup_id,
            adapter: Geolix.Adapter.LookupCache,
            cache: %{
              id: :my_cache_id,
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

  ## Lookup Adapter Configuration

  The configuration for your lookup adapter should contain at least the
  `:adapter` key to select the proper adapter. The `:id` value will
  automatically be set to the main database id and is not configurable.

  Please consult the used adapter's documentation for additional requirements
  and options.

  ## Cache Adapter Configuration

  A map with at least an `:id` and an `:adapter` key is required to define
  the cache to use.

  Please consult the used adapter's documentation for additional requirements
  and options.

  ### Cache Adapter Implementation

  Adapters for the following cache libraries are pre-packaged:

  - `Geolix.Adapter.LookupCache.CacheAdapter.Cachex`
  - `Geolix.Adapter.LookupCache.CacheAdapter.ConCache`
  - `Geolix.Adapter.LookupCache.CacheAdapter.Fake`

  To use any of these you also need to add the library itself as a dependency
  to your application. The compatible versions used for testing are configured
  as optional dependencies of `:geolix_adapter_lookup_cache`.

  If you intend to use a custom cache adapter you should adhere to the
  `Geolix.Adapter.LookupCache.CacheAdapter` behaviour.
  """

  @behaviour Geolix.Adapter

  @impl Geolix.Adapter
  def database_workers(%{
        id: database_id,
        cache: %{adapter: cache_adapter} = cache,
        lookup: %{adapter: database_adapter} = database
      }) do
    database = Map.put(database, :id, database_id)

    cache_workers =
      if Code.ensure_loaded?(cache_adapter) and
           function_exported?(cache_adapter, :cache_workers, 2) do
        cache_adapter.cache_workers(database, cache)
      else
        []
      end

    database_workers =
      if Code.ensure_loaded?(database_adapter) and
           function_exported?(database_adapter, :database_workers, 1) do
        database_adapter.database_workers(database)
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
    database = Map.put(database, :id, database_id)

    if Code.ensure_loaded?(cache_adapter) and function_exported?(cache_adapter, :load_cache, 2) do
      :ok = cache_adapter.load_cache(database, cache)
    end

    if Code.ensure_loaded?(database_adapter) do
      if function_exported?(database_adapter, :load_database, 1) do
        database_adapter.load_database(database)
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
  def metadata(%{
        id: database_id,
        lookup: %{adapter: database_adapter} = database
      }) do
    if function_exported?(database_adapter, :metadata, 1) do
      database
      |> Map.put(:id, database_id)
      |> database_adapter.metadata()
    else
      nil
    end
  end

  @impl Geolix.Adapter
  def unload_database(%{
        id: database_id,
        cache: %{adapter: cache_adapter} = cache,
        lookup: %{adapter: database_adapter} = database
      }) do
    database = Map.put(database, :id, database_id)

    if function_exported?(cache_adapter, :unload_cache, 2) do
      :ok = cache_adapter.unload_cache(database, cache)
    end

    if function_exported?(database_adapter, :unload_database, 1) do
      database_adapter.unload_database(database)
    else
      :ok
    end
  end
end
