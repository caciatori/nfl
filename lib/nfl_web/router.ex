defmodule NflWeb.Router do
  use NflWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {NflWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NflWeb do
    pipe_through :browser

    live "/players", PlayerLive
    get "/players/export", PlayerController, :export
  end

  # Other scopes may use custom stacks.
  # scope "/api", NflWeb do
  #   pipe_through :api
  # end
end
