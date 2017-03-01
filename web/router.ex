defmodule ZionRecs.Router do
  use ZionRecs.Web, :router

  pipeline :products do
    plug :accepts, ["json"]
  end

  scope "/v1/products", ZionRecs do
    pipe_through :products

    resources "/products", ProductController
    post "/", ProductController, :create
    get "/last_seen/:user_id", ProductController, :show_last_seen
    get "/most_viewed/:category_id", ProductController, :show_most_viewed
    get "/common_views/:product_id", ProductController, :show_common_views
  end
end
