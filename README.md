# RecommendationsEx
[![Build Status](https://travis-ci.org/victorspringer/recommendationsEx.svg?branch=master)](https://travis-ci.org/victorspringer/recommendationsEx)

This is an under development recommendation engine built with Elixir Phoenix and Neo4j graph database.

The purpose of this API is to provide product recommendations based on users navigation history through your e-commerce products.

Feedbacks and pull requests are very welcome!

## Getting Started

First of all, you must download [`Neo4j graph database`](https://neo4j.com/download) (the version used in this project is 3.1.1) and change the database connection settings accordingly to your own configuration at `/config`.

To start the API server:

  * Install dependencies with `mix deps.get`
  * Navigate to your Neo4j directory and start its server with `./bin/neo4j console`
  * Start Phoenix endpoint with `mix phoenix.server`

You can check your graph at [`Neo4j web interface`](http://localhost:7474)

The current features of the API are:

  * Last seen products (`/last_seen/:user_id`)
  * Most viewed products in category (`/most_viewed/:category_id`)
  * Who has viewed this, viewed also... (`/common_views/:product_id`)

You can optionally add the query string parameter `?limit=:value` to set a custom number of results. The default value is 5.

Ready to run in production? Please [check the deployment guides](http://www.phoenixframework.org/docs/deployment).

## Data insertion format

`user.user_id`, `category.category_id`, `product.product_id` are the only required properties.

Besides that, it's possible to set whatever property you need.

Here is an example of a post request sent via JavaScript:

```javascript
const xhr = new XMLHttpRequest();
xhr.open('POST', 'http://localhost:4000/v1/products', true);
xhr.setRequestHeader('Content-Type', 'application/json');
xhr.send(JSON.stringify({
  user: {
    user_id: 'U12345',
    foo: 'bar'
  },
  category: {
    category_id: 'C12345',
    bar: 'baz'
  },
  product: {
    product_id: 'P12345',
    etc: '...'
  }
}));
```
