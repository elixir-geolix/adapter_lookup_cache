defmodule Geolix.Adapter.LookupCache.CacheAdapter.FakeTest do
  use ExUnit.Case

  alias Geolix.Adapter.LookupCache.CacheAdapter.Fake

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

  test "fake adapter mfargs using {mod, fun}", %{test: test} do
    ip = {1, 1, 1, 1}
    result = %{test: :result}

    database = %{
      id: test,
      adapter: Geolix.Adapter.LookupCache,
      cache: %{
        id: :test_cache,
        adapter: Fake,
        mfargs_get: {MFArgsSender, :notify},
        mfargs_put: {MFArgsSender, :notify},
        notify: self()
      },
      lookup: %{
        adapter: Geolix.Adapter.Fake,
        data: %{ip => result}
      }
    }

    _ = Geolix.load_database(database)
    _ = Geolix.lookup(ip, where: database[:id])
    _ = Geolix.unload_database(database)

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
        adapter: Fake,
        mfargs_get: {MFArgsSender, :notify, [:get]},
        mfargs_put: {MFArgsSender, :notify, [:put]},
        notify: self()
      },
      lookup: %{
        adapter: Geolix.Adapter.Fake,
        data: %{ip => result}
      }
    }

    _ = Geolix.load_database(database)
    _ = Geolix.lookup(ip, where: database[:id])
    _ = Geolix.unload_database(database)

    assert_receive :get
    assert_receive :put
  end
end
