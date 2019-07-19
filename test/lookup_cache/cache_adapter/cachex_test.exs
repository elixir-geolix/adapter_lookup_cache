defmodule Geolix.Adapter.LookupCache.CacheAdapter.CachexTest do
  use ExUnit.Case

  alias Geolix.Adapter.LookupCache.CacheAdapter.Cachex, as: CachexCacheAdapter

  test "lookup" do
    database = %{
      id: :lookup_cache_cachex,
      adapter: Geolix.Adapter.LookupCache,
      cache: %{
        id: :lookup_cache_cachex_cache,
        adapter: CachexCacheAdapter
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

    assert :ok == CachexCacheAdapter.put(ip, database[:lookup], [], database[:cache], result)

    assert result == Geolix.lookup(ip, where: database[:id])
  end
end
