defmodule Geolix.Adapter.LookupCacheTest do
  use ExUnit.Case

  test "lookup" do
    database = %{
      id: :lookup_cache,
      adapter: Geolix.Adapter.LookupCache,
      lookup: %{
        adapter: Geolix.Adapter.Fake,
        data: %{{1, 1, 1, 1} => :lookup_result}
      }
    }

    assert :ok == Geolix.load_database(database)
    assert :lookup_result == Geolix.lookup({1, 1, 1, 1}, where: :lookup_cache)
  end
end
