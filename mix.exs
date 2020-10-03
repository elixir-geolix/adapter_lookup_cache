defmodule Geolix.Adapter.LookupCache.MixProject do
  use Mix.Project

  @url_github "https://github.com/elixir-geolix/adapter_lookup_cache"

  def project do
    [
      app: :geolix_adapter_lookup_cache,
      name: "Geolix Adapter: Lookup Cache",
      version: "0.3.0-dev",
      elixir: "~> 1.7",
      deps: deps(),
      description: "Lookup cache adapter for Geolix",
      dialyzer: dialyzer(),
      docs: docs(),
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.travis": :test
      ],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:cachex, "~> 3.0", optional: true},
      {:con_cache, "~> 0.14.0", optional: true},
      {:credo, "~> 1.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.13.0", only: :test, runtime: false},
      {:geolix, "~> 2.0"}
    ]
  end

  defp dialyzer do
    [
      flags: [
        :error_handling,
        :race_conditions,
        :underspecs,
        :unmatched_returns
      ],
      plt_add_apps: [:cachex, :con_cache]
    ]
  end

  defp docs do
    [
      groups_for_modules: [
        Adapters: [
          Geolix.Adapter.LookupCache.CacheAdapter.Cachex,
          Geolix.Adapter.LookupCache.CacheAdapter.ConCache,
          Geolix.Adapter.LookupCache.CacheAdapter.Fake
        ]
      ],
      main: "Geolix.Adapter.LookupCache",
      nest_modules_by_prefix: [
        Geolix.Adapter,
        Geolix.Adapter.LookupCache.CacheAdapter
      ],
      source_ref: "master",
      source_url: @url_github
    ]
  end

  defp package do
    %{
      files: ["CHANGELOG.md", "LICENSE", "mix.exs", "README.md", "lib"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => @url_github}
    }
  end
end
