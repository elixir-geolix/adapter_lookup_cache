defmodule Geolix.Adapter.LookupCache.CacheAdapter.Fake do
  @moduledoc """
  Fake adapter for testing environments.

  ## Usage

      %{
        cache: %{
          id: :name_of_the_cache
          adapter: Geolix.Adapter.LookupCache.CacheAdapter.Fale
        }
      }

  This adapter will ignore all get/put requests and force all lookup requests
  to be passed to the original lookup adapter.
  """

  @behaviour Geolix.Adapter.LookupCache.CacheAdapter

  @impl Geolix.Adapter.LookupCache.CacheAdapter
  def get(_, _, _, _), do: {:ok, nil}

  @impl Geolix.Adapter.LookupCache.CacheAdapter
  def put(_, _, _, _, _), do: :ok
end
