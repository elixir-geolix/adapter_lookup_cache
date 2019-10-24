defmodule Geolix.Adapter.LookupCache.CacheAdapter.FakeTest do
  use ExUnit.Case

  alias Geolix.Adapter.LookupCache.CacheAdapter.Fake

  test "lookup" do
    ip = {1, 1, 1, 1}
    result = %{test: :result}

    database = %{
      id: :lookup_cache_fake,
      adapter: Geolix.Adapter.LookupCache,
      cache: %{
        id: :lookup_cache_fake_cache,
        adapter: Fake
      },
      lookup: %{
        adapter: Geolix.Adapter.Fake,
        data: %{ip => result}
      }
    }

    assert :ok == Geolix.load_database(database)
    assert result == Geolix.lookup(ip, where: database[:id])
  end
end
