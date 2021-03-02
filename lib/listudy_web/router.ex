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
    plug ListudyWeb.Plugs.CSP
    plug ListudyWeb.Plugs.LastVisited
    plug NavigationHistory.Tracker
  end

  pipeline :iframe do
    plug :put_layout, {ListudyWeb.LayoutView, :iframe}
    plug ListudyWeb.Plugs.AllowIframe
  end

  pipeline :admin do
    plug ListudyWeb.EnsureRolePlug, :admin
  end

  pipeline :stockfish do
    plug ListudyWeb.Plugs.Stockfish
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

    resources "/studies", StudyController, as: :admin_study
    get "/blog", PostController, :index_all
    get "/blog/:id/edit", PostController, :edit
    get "/blog/new", PostController, :new
    post "/blog", PostController, :create
    put "/blog/:id", PostController, :update
    delete "/blog/:id", PostController, :delete
    get "/", PageController, :index

    resources "/blog_faq", BlogFaqController
    resources "/opening_faq", OpeningFaqController

    resources "/motifs", MotifController
    resources "/openings", OpeningController
    resources "/players", PlayerController
    resources "/events", EventController
    resources "/tactics", TacticController

    resources "/book_opening", BookOpeningController
    resources "/book_tag", BookTagController
    resources "/books", BookController
    resources "/tags", TagController
    resources "/authors", AuthorController
    resources "/expert_recommendation", ExpertRecommendationController

    resources "/blind_tactics", BlindTacticController
  end

  scope "/:locale", ListudyWeb do
    pipe_through [:browser, :stockfish]
    get "/play-stockfish", PageController, :play_stockfish
    get "/endgames/:chapter/:subchapter/:game", EndgameController, :game
  end

  scope "/:locale/iframe", ListudyWeb do
    pipe_through [:browser, :iframe]
    get "/custom-tactic", IframeController, :custom_tactic
  end

  scope "/:locale", ListudyWeb do
    pipe_through :browser

    get "/sitemap.xml", SitemapController, :index
    get "/sitemap.books.xml", SitemapController, :books
    live "/studies/search", StudySearchLive, layout: {ListudyWeb.LayoutView, :live}, as: :search
    live "/events", EventSearchLive, layout: {ListudyWeb.LayoutView, :live}, as: :event_search

    live "/openings", OpeningSearchLive,
      layout: {ListudyWeb.LayoutView, :live},
      as: :opening_search

    live "/players", PlayerSearchLive, layout: {ListudyWeb.LayoutView, :live}, as: :player_search
    live "/motif", MotifSearchLive, layout: {ListudyWeb.LayoutView, :live}, as: :motif_search

    get "/events/:event", EventController, :show
    get "/players/:player", PlayerController, :show
    get "/openings/:opening", OpeningController, :show
    get "/motif/:motif", MotifController, :show

    get "/tactics", TacticController, :random
    get "/tactics/daily-puzzle", TacticController, :daily
    get "/tactics/custom", TacticController, :custom
    get "/tactics/opening/:opening", TacticController, :random, as: :random_opening_tactic
    get "/tactics/event/:event", TacticController, :random, as: :random_event_tactic
    get "/tactics/player/:player", TacticController, :random, as: :random_player_tactic
    get "/tactics/motif/:motif", TacticController, :random, as: :random_motif_tactic

    get "/endgames", EndgameController, :index
    get "/endgames/:chapter", EndgameController, :chapter

    get "/blind-tactics", BlindTacticController, :random

    live "/blind-tactics/:id", BlindTacticsLive,
      layout: {ListudyWeb.LayoutView, :live},
      as: :blind_tactics

    live "/games/chessclicker", ChessClickerLive,
      layout: {ListudyWeb.LayoutView, :live},
      as: :chesslicker_tactics

    live "/tactics/:id", TacticsLive, layout: {ListudyWeb.LayoutView, :live}, as: :tactics

    live "/tactics/opening/:opening/:id", TacticsLive,
      layout: {ListudyWeb.LayoutView, :live},
      as: :opening_tactics

    live "/tactics/motif/:motif/:id", TacticsLive,
      layout: {ListudyWeb.LayoutView, :live},
      as: :motif_tactics

    live "/tactics/event/:event/:id", TacticsLive,
      layout: {ListudyWeb.LayoutView, :live},
      as: :event_tactics

    live "/tactics/player/:player/:id", TacticsLive,
      layout: {ListudyWeb.LayoutView, :live},
      as: :player_tactics

    get "/books/best-chess-books", BookController, :recommended
    get "/books/list/:slug", TagController, :show
    get "/books/author/:slug", AuthorController, :show
    get "/books/:slug", BookController, :show
    live "/books", BookSearchLive, layout: {ListudyWeb.LayoutView, :live}, as: :book_search

    resources "/studies", StudyController
    get "/blog", PostController, :index
    get "/blog/:id", PostController, :show
    get "/stats", StatsController, :index
    get "/profile/:username", UserProfileController, :show
    get "/features/:page", PageController, :features
    get "/webmaster/:page", WebmasterController, :show
    get "/webmaster", WebmasterController, :index
    get "/:page", PageController, :show
    get "/", PageController, :index
  end

  scope "/", ListudyWeb do
    pipe_through [:browser, :logged_in]

    post "/comment", CommentController, :new_comment
    delete "/comment/:type/:id", CommentController, :delete_comment
    post "/study_favorite/:slug", StudyController, :favorite_study
    post "/study_unfavorite/:slug", StudyController, :unfavorite_study
  end

  scope "/", ListudyWeb do
    pipe_through :browser

    get "/", PageController, :domain
  end
end
