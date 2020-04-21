defmodule Geolix.Adapter.LookupCache.CacheAdapter.Cachex do
  @moduledoc """
  Cache adpater for `:cachex`.

  ## Usage

      %{
        cache: %{
          id: :name_of_the_cache
          adapter: Geolix.Adapter.LookupCache.CacheAdapter.Cachex,
          options: [
            # additional options as required
          ]
        }
      }

  The `:id` for `:cachex` will be automatically set to the `:id` of the
  cache configuration.
  """

  @behaviour Geolix.Adapter.LookupCache.CacheAdapter

  @impl Geolix.Adapter.LookupCache.CacheAdapter
  def cache_workers(_database, %{id: cache_id} = cache) do
    [
      %{
        id: cache_id,
        start: {Cachex, :start_link, [cache_id, Map.get(cache, :options, [])]}
      }
    ]
  end

  @impl Geolix.Adapter.LookupCache.CacheAdapter
  def get(ip, _, _, %{id: cache_id}) do
    Cachex.get(cache_id, ip)
  end

  @impl Geolix.Adapter.LookupCache.CacheAdapter
  def put(ip, _, _, %{id: cache_id}, result) do
    _ = Cachex.put(cache_id, ip, result)

    :ok
  end
end
