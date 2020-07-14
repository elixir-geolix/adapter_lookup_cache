defmodule Geolix.Adapter.LookupCache.CacheAdapter.FakeTest do
  use ExUnit.Case

  alias Geolix.Adapter.LookupCache.CacheAdapter.Fake, as: FakeCacheAdapter

  defmodule MFArgsSender do
    def notify(database, %{notify: pid}), do: send(pid, database)
    def notify(_, %{notify: pid}, extra_arg), do: send(pid, extra_arg)
  end

  test "lookup" do
    ip = {1, 1, 1, 1}
    result = %{test: :result}

    database = %{
      id: :lookup_cache_fake,
      adapter: Geolix.Adapter.LookupCache,
      cache: %{
        id: :lookup_cache_fake_cache,
        adapter: FakeCacheAdapter
      },
      lookup: %{
        adapter: Geolix.Adapter.Fake,
        data: %{ip => result}
      }
    }

    assert :ok == Geolix.load_database(database)
    assert result == Geolix.lookup(ip, where: database[:id])
  end

  test "fake adapter mfargs using {mod, fun}", %{test: test} do
    ip = {1, 1, 1, 1}
    result = %{test: :result}

    database = %{
      id: test,
      adapter: Geolix.Adapter.LookupCache,
      cache: %{
        id: :test_cache,
        adapter: FakeCacheAdapter,
        mfargs_cache_workers: {MFArgsSender, :notify},
        mfargs_get: {MFArgsSender, :notify},
        mfargs_load_cache: {MFArgsSender, :notify},
        mfargs_put: {MFArgsSender, :notify},
        mfargs_unload_cache: {MFArgsSender, :notify},
        notify: self()
      },
      lookup: %{
        adapter: Geolix.Adapter.Fake,
        data: %{ip => result}
      }
    }

    _ = Geolix.load_database(database)
    _ = Geolix.lookup(ip, where: database[:id])
    _ = Geolix.unload_database(database[:id])

    assert_receive %{id: ^test}
    assert_receive %{id: ^test}
    assert_receive %{id: ^test}
    assert_receive %{id: ^test}
    assert_receive %{id: ^test}
  end

  test "fake adapter mfargs using {mod, fun, extra_args}", %{test: test} do
    ip = {1, 1, 1, 1}
    result = %{test: :result}

    database = %{
      id: test,
      adapter: Geolix.Adapter.LookupCache,
      cache: %{
        id: :test_cache,
        adapter: FakeCacheAdapter,
        mfargs_cache_workers: {MFArgsSender, :notify, [:cache_workers]},
        mfargs_get: {MFArgsSender, :notify, [:get]},
        mfargs_load_cache: {MFArgsSender, :notify, [:load_cache]},
        mfargs_put: {MFArgsSender, :notify, [:put]},
        mfargs_unload_cache: {MFArgsSender, :notify, [:unload_cache]},
        notify: self()
      },
      lookup: %{
        adapter: Geolix.Adapter.Fake,
        data: %{ip => result}
      }
    }

    _ = Geolix.load_database(database)
    _ = Geolix.lookup(ip, where: database[:id])
    _ = Geolix.unload_database(database[:id])

    assert_receive :cache_workers
    assert_receive :load_cache
    assert_receive :get
    assert_receive :put
    assert_receive :unload_cache
  end
end
