defmodule ZionRecs.ProductController do
  use ZionRecs.Web, :controller

  # Product click
  def create(conn, %{"user" => user_params, "category" => category_params, "product" => product_params}) do
    db_conn = Repo.conn

    user_id = user_params["user_id"]
    user = user_params |> Utils.encode_params

    category_id = category_params["category_id"]
    category = category_params |> Utils.encode_params

    product_id = product_params["product_id"]
    product = product_params |> Utils.encode_params

    query = "
      MERGE (user:User {user_id: \"#{user_id}\"}) SET user = {#{user}}
      MERGE (category:Category {category_id: \"#{category_id}\"}) SET category = {#{category}}
      MERGE (product:Product {product_id: \"#{product_id}\"}) SET product = {#{product}}
      MERGE (product)-[:BELONGS_TO]->(category)
      CREATE (user)-[:CLICKED {clicked_at: timestamp()}]->(product)
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
      MATCH (user:User {user_id: \"#{user_id}\"})-[clicked:CLICKED]->(product:Product)
      WITH product.product_id AS product_id, product AS product
      ORDER BY clicked.clicked_at DESC
      
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
      WHERE category.category_id = \"#{category_id}\"
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
      MATCH (product:Product)<-[clicked:CLICKED]-(user:User),
        (user)-[currentClick:CLICKED]->(clicked_product:Product {product_id: \"#{product_id}\"})
      WHERE (currentClick.clicked_at - clicked.clicked_at) <= 180000
        AND (currentClick.clicked_at - clicked.clicked_at) > -180000
        AND product.product_id <> \"#{product_id}\"
      WITH product.product_id AS product_id, product AS product
      ORDER BY clicked.clicked_at DESC
      
      RETURN DISTINCT product_id LIMIT #{limit}
    "

    products = Repo.query!(db_conn, query)
    |> Enum.map(fn(%{"product_id" => product_id}) ->
      product_id
    end)

    json conn, products
  end
end
