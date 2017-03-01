defmodule ZionRecs.ProductController do
  use ZionRecs.Web, :controller

  # Product click
  def create(conn, %{"user" => user_params, "category" => category_params, "product" => product_params}) do
    db_conn = Repo.conn

    user_id = user_params["user_id"]
    user = user_params |> Utils.encode_params

    category_id = category_params["category_id"]
    category = category_params |> Utils.encode_params

    product = product_params |> Utils.encode_params

    query = "
      MERGE (user:User {user_id: \"#{user_id}\"}) SET user = {#{user}}
      MERGE (category:Category {category_id: \"#{category_id}\"}) SET category = {#{category}}

      CREATE (product:Product {#{product}, clicked_at: timestamp()}),
        (user)-[:CLICKED]->(product),
        (product)-[:BELONGS_TO]->(category)
    "

    response = Repo.query!(db_conn, query)

    case Map.fetch(response, :stats) do
      {:ok, stats} ->
        json conn, true
      {:error, stats} ->
        json conn, false
    end
  end

  # Last seen products
  def show_last_seen(conn, params) do
    user_id = params["user_id"]
    limit = if params["limit"], do: params["limit"], else: 5

    db_conn = Repo.conn

    query = "
      MATCH (user:User {user_id: \"#{user_id}\"})-[:CLICKED]->(product:Product)
      WITH product.product_id AS product_id, product AS product
      ORDER BY product.clicked_at DESC
      
      RETURN DISTINCT product_id LIMIT #{limit}
    "

    products = Repo.query!(db_conn, query)
    |> Enum.map(fn(%{"product_id" => product_id}) ->
      product_id
    end)

    json conn, products
  end

  # Most viewed products in category
  def show_most_viewed(conn, params) do
    category_id = params["category_id"]
    limit = if params["limit"], do: params["limit"], else: 5

    db_conn = Repo.conn

    query = "
      MATCH (product:Product)-[:BELONGS_TO]->(category:Category)
      
      RETURN COUNT(*) AS occurrence, product.product_id AS product_id
      ORDER BY occurrence DESC LIMIT #{limit}
    "

    products = Repo.query!(db_conn, query)
    |> Enum.map(fn(%{"product_id" => product_id}) ->
      product_id
    end)

    json conn, products
  end

  # Who has viewed this, viewed also...
  def show_common_views(conn, params) do
    product_id = params["product_id"]
    limit = if params["limit"], do: params["limit"], else: 5

    db_conn = Repo.conn

    query = "
      MATCH (product:Product)<-[:CLICKED]-(user:User),
        (user)-[:CLICKED]->(clicked_product:Product {product_id: \"#{product_id}\"})
      WHERE (clicked_product.clicked_at - product.clicked_at) <= 1800000
        AND (clicked_product.clicked_at - product.clicked_at) > -1800000
      WITH product.product_id AS product_id, product AS product
      ORDER BY product.clicked_at DESC
      
      RETURN DISTINCT product_id LIMIT #{limit}
    "

    products = Repo.query!(db_conn, query)
    |> Enum.map(fn(%{"product_id" => product_id}) ->
      product_id
    end)

    json conn, products
  end
end
