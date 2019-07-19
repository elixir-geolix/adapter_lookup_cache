defmodule Geolix.Adapter.LookupCache.CacheAdapter.ConCacheTest do
  use ExUnit.Case

  alias Geolix.Adapter.LookupCache.CacheAdapter.ConCache, as: ConCacheCacheAdapter

  test "lookup" do
    database = %{
      id: :lookup_cache_con_cache,
      adapter: Geolix.Adapter.LookupCache,
      cache: %{
        id: :lookup_cache_con_cache_cache,
        adapter: ConCacheCacheAdapter
      },
      lookup: %{
        adapter: Geolix.Adapter.Fake,
        data: %{}
      }
    }

    ip = {1, 1, 1, 1}
    result = %{test: :result}

    assert :ok == Geolix.load_database(database)
    assert nil == Geolix.lookup(ip, where: database[:id])

    assert :ok == ConCacheCacheAdapter.put(ip, database[:lookup], [], database[:cache], result)

    assert result == Geolix.lookup(ip, where: database[:id])
  end
end
