defmodule KimperWeb.Router do
  use KimperWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {KimperWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KimperWeb do
    pipe_through :browser

    # get "/", PageController, :home
    live "/", HomeLive
    get "/sitemap.xml", SitemapController, :index # 참고: https://andrewian.dev/blog/sitemap-in-phoenix-with-verified-routes
  end

  # Other scopes may use custom stacks.
  # scope "/api", KimperWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:kimper, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: KimperWeb.Telemetry
    end
  end
end
