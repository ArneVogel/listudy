defmodule ListudyWeb.Router do
  use ListudyWeb, :router
  use Pow.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ListudyWeb.Plugs.Locale, "en"
    plug NavigationHistory.Tracker
  end

  pipeline :admin do
    plug ListudyWeb.EnsureRolePlug, :admin
  end

  pipeline :logged_in do
    plug Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :browser

    pow_routes()
  end

  scope "/admin", ListudyWeb do
    pipe_through [:browser, :admin]

    get "/blog", PostController, :index_all
    get "/blog/:id/edit", PostController, :edit
    get "/blog/:id/new", PostController, :new
    post "/blog", PostController, :create
    put "/blog/:id", PostController, :update
    delete "/blog/:id", PostController, :delete
    get "/", PageController, :index
  end

  scope "/:locale", ListudyWeb do
    pipe_through :browser

    live "/studies/search", StudySearchLive, layout: {ListudyWeb.LayoutView, :live}, as: :search
    resources "/studies", StudyController
    get "/blog", PostController, :index
    get "/blog/:id", PostController, :show
    get "/profile/:username", UserProfileController, :show
    get "/:page", PageController, :show
    get "/", PageController, :index
  end

  scope "/", ListudyWeb do
    pipe_through [:browser, :logged_in]

    post "/comment", CommentController, :new_comment
    delete "/comment/:type/:id", CommentController, :delete_comment
    post "/study_favorite", StudyController, :favorite_study
    post "/study_unfavorite", StudyController, :unfavorite_study
  end


  scope "/", ListudyWeb do
    pipe_through :browser

    get "/", PageController, :domain
  end


  # Other scopes may use custom stacks.
  # scope "/api", ListudyWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ListudyWeb.Telemetry
    end
  end
end
