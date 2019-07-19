defmodule Geolix.Adapter.LookupCache.CacheAdapter.ConCache do
  @moduledoc """
  Cache adpater for `:con_cache`
  """

  @behaviour Geolix.Adapter.LookupCache.CacheAdapter

  @impl Geolix.Adapter.LookupCache.CacheAdapter
  def cache_workers(_database, %{id: cache_id}) do
    import Supervisor.Spec

    [supervisor(ConCache, [[name: cache_id, ttl_check_interval: false]])]
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
