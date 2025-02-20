defmodule KimperWeb.SitemapHtml do
  use KimperWeb, :html

  embed_templates "sitemap_html/*"

  def pages do
    [
      ~p"/",
    ]
  end

  defmacro today do
    quote do
      Date.utc_today()
    end
  end

  def show_pages do
    for path <- pages() do
      route = KimperWeb.Endpoint.url() <> path

      """
      <url>
        <loc>#{route}</loc>
        <lastmod>#{today()}</lastmod>
        <priority>0.5</priority>
        <changefreq>weekly</changefreq>
      </url>
      """
    end
  end
end
