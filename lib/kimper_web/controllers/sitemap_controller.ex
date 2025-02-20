defmodule KimperWeb.SitemapController do
  use KimperWeb, :controller

  def index(conn, _params) do
    xml = KimperWeb.SitemapHtml.index(%{})

    conn
    |> put_resp_content_type("text/xml")
    |> text(xml)
  end

end
