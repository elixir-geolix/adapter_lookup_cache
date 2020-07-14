defmodule Geolix.Adapter.LookupCache.CacheAdapter.Fake do
  @moduledoc """
  Fake adapter for testing environments.

  ## Usage

      %{
        cache: %{
          id: :name_of_the_cache,
          adapter: Geolix.Adapter.LookupCache.CacheAdapter.Fale
        }
      }

  This adapter will ignore all get/put requests and force all lookup requests
  to be passed to the original lookup adapter.
  """

  alias Geolix.Adapter.LookupCache.CacheAdapter

  @behaviour CacheAdapter

  @impl CacheAdapter
  def cache_workers(database, cache) do
    :ok = maybe_apply_mfargs(database, cache, :mfargs_cache_workers)

    []
  end

  @impl CacheAdapter
  def get(_, _, database, cache) do
    :ok = maybe_apply_mfargs(database, cache, :mfargs_get)

    {:ok, nil}
  end

  @impl CacheAdapter
  def load_cache(database, cache) do
    :ok = maybe_apply_mfargs(database, cache, :mfargs_load_cache)
    :ok
  end

  @impl CacheAdapter
  def put(_, _, database, cache, _) do
    :ok = maybe_apply_mfargs(database, cache, :mfargs_put)
    :ok
  end

  @impl CacheAdapter
  def unload_cache(database, cache) do
    :ok = maybe_apply_mfargs(database, cache, :mfargs_unload_cache)
    :ok
  end

  defp maybe_apply_mfargs(database, cache, key) do
    _ =
      case Map.get(cache, key) do
        {mod, fun, extra_args} -> apply(mod, fun, [database, cache | extra_args])
        {mod, fun} -> apply(mod, fun, [database, cache])
        nil -> :ok
      end

    :ok
  end
end
