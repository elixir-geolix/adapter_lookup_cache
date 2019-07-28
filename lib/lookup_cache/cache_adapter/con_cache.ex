defmodule Geolix.Adapter.LookupCache.CacheAdapter.ConCache do
  @moduledoc """
  Cache adpater for `:con_cache`.

  ## Usage

      %{
        cache: %{
          id: :name_of_the_cache
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

  @behaviour Geolix.Adapter.LookupCache.CacheAdapter

  @impl Geolix.Adapter.LookupCache.CacheAdapter
  def cache_workers(_database, %{id: cache_id} = cache) do
    import Supervisor.Spec

    options =
      cache
      |> Map.get(:options, [])
      |> Keyword.put_new(:name, cache_id)
      |> Keyword.put_new(:ttl_check_interval, false)

    [supervisor(ConCache, [options])]
  end

  @impl Geolix.Adapter.LookupCache.CacheAdapter
  def get(ip, _, _, %{id: cache_id}) do
    value = ConCache.get(cache_id, ip)

    {:ok, value}
  end

  @impl Geolix.Adapter.LookupCache.CacheAdapter
  def put(ip, _, _, %{id: cache_id}, result) do
    ConCache.put(cache_id, ip, result)
  end
end