defmodule Geolix.Adapter.LookupCache.CacheAdapter do
  @moduledoc """
  Behaviour a cache adapter is expected to follow.
  """

  @optional_callbacks [
    cache_workers: 2
  ]

  @doc """
  Returns the children to be supervised for this cache.

  If no automatic supervision should take place or it is intended to use an
  adapter specific supervisor (e.g. using the application config) this callback
  should be either unimplemented or return an empty list.
  """
  @callback cache_workers(database :: map, cache :: map) :: list

  @doc """
  Perform a cache lookup and return the result.

  The result value is treated as follows:

  - `{:ok, nil}` - No cached value found, will be updated after lookup
  - `{:ok, map}` - Cached value found, will be returned directly to caller
  - `{:error, term}` - Cache error, lookup will not be saved to cache
  """
  @callback get(ip :: :inet.ip_address(), opts :: Keyword.t(), database :: map, cache :: map) ::
              {:ok, map | nil} | {:error, term}

  @doc """
  Store a lookup result in the cache.

  The adapter should (for now) always return `:ok` and handle errors internally.
  """
  @callback put(
              ip :: :inet.ip_address(),
              opts :: Keyword.t(),
              database :: map,
              cache :: map,
              result :: map | nil
            ) ::
              :ok
end
