defmodule KimperWeb.SitemapController do

  def generate_sitemap() do
    config = [
      store_config: [
        path: "priv/static/",
      ],
      sitemap_url: "https://kimper.gigalixirapp.com/"
    ]

    Stream.concat([1..100_001])
    |> Stream.map(fn _ ->
      %Sitemapper.URL{
        loc: "https://kimper.gigalixirapp.com/",
        changefreq: :weekly,
        lastmod: Date.utc_today()
      }
    end)
    |> Sitemapper.generate(config)
    |> Sitemapper.persist(config)
    |> Stream.run()
  end
end
