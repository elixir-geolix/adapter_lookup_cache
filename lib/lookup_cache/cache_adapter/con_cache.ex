defmodule Geolix.Adapter.LookupCache.CacheAdapter.ConCache do
  @moduledoc """
  Cache adapter for `:con_cache`.

  ## Usage

      %{
        cache: %{
          id: :name_of_the_cache,
          adapter: Geolix.Adapter.LookupCache.CacheAdapter.ConCache,
          options: [
            # additional options as required
          ]
        }
      }

  The `:name` option of the cache will be set to the `:id` of the cache
  configuration if you do not define a custom value.

  If you do not define a `:ttl_check_interval` it will be set to `false`.
  """

  alias Geolix.Adapter.LookupCache.CacheAdapter

  @behaviour CacheAdapter

  @impl CacheAdapter
  def cache_workers(_database, %{id: cache_id} = cache) do
    options =
      cache
      |> Map.get(:options, [])
      |> Keyword.put_new(:name, cache_id)
      |> Keyword.put_new(:ttl_check_interval, false)

    [
      %{
        id: cache_id,
        start: {ConCache, :start_link, [options]},
        type: :supervisor
      }
    ]
  end

  @impl CacheAdapter
  def get(ip, _, _, %{id: cache_id}) do
    value = ConCache.get(cache_id, ip)

    {:ok, value}
  end

  @impl CacheAdapter
  def put(ip, _, _, %{id: cache_id}, result) do
    ConCache.put(cache_id, ip, result)
  end
end
