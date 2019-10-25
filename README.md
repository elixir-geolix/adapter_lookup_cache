# Geolix Adapter: Lookup Cache

Lookup cache adapter for [`Geolix`](https://github.com/elixir-geolix/geolix).

## Package Setup

To use the Lookup Cache Adapter with your projects, edit your `mix.exs` file and add the required dependencies:

```elixir
defp deps do
  [
    # ...
    {:geolix_adapter_lookup_cache, "~> 0.1.0"},
    {:your_geolix_adapter_of_choice, "~> 0.1.0"},
    # ...
  ]
end
```

An appropriate version of `:geolix` should automatically be selected by both the cache and lookup adapter's dependency trees.

## Adapter Configuration

To start using the adapter with a lookup adapter you need to add the required configuration entry to your `:geolix` configuration:

```elixir
config :geolix,
  databases: [
    %{
      id: :my_lookup_id,
      adapter: Geolix.Adapter.LookupCache,
      cache: %{
        id: :my_cache_id
        adapter: MyCacheAdapter
      },
      lookup: %{
        adapter: MyLookupAdapter
      }
    }
  ]
```

The id of the main database configuration will be used for the lookup adapter and automatically passed when required.

## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)
