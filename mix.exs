defmodule Geolix.Adapter.LookupCache.MixProject do
  use Mix.Project

  @url_changelog "https://hexdocs.pm/geolix_adapter_lookup_cache/changelog.html"
  @url_github "https://github.com/elixir-geolix/adapter_lookup_cache"
  @version "0.3.0-dev"

  def project do
    [
      app: :geolix_adapter_lookup_cache,
      name: "Geolix Adapter: Lookup Cache",
      version: @version,
      elixir: "~> 1.9",
      deps: deps(),
      description: "Lookup cache adapter for Geolix",
      dialyzer: dialyzer(),
      docs: docs(),
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test
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
      {:con_cache, "~> 1.0", optional: true},
      {:credo, "~> 1.6", only: :dev, runtime: false},
      {:dialyxir, "~> 1.2", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.15.0", only: :test, runtime: false},
      {:geolix, "~> 2.0"}
    ]
  end

  defp dialyzer do
    [
      flags: [
        :error_handling,
        :underspecs,
        :unmatched_returns
      ],
      plt_add_apps: [:cachex, :con_cache],
      plt_core_path: "plts",
      plt_local_path: "plts"
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md",
        LICENSE: [title: "License"],
        "README.md": [title: "Overview"]
      ],
      formatters: ["html"],
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
      source_ref: "v#{@version}",
      source_url: @url_github
    ]
  end

  defp package do
    [
      files: ["CHANGELOG.md", "LICENSE", "mix.exs", "README.md", "lib"],
      licenses: ["Apache-2.0"],
      links: %{
        "Changelog" => @url_changelog,
        "GitHub" => @url_github
      }
    ]
  end
end
