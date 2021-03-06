# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
#config :recommendationsEx,
#  ecto_repos: [RecommendationsEx.Repo]

# Configures the endpoint
config :recommendationsEx, RecommendationsEx.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "69XseFy0zebJRkekGH1nQsurxQpafhOav+ijiA0UTHnv5aV49nabjOvngN6fEKXb",
  render_errors: [view: RecommendationsEx.ErrorView, accepts: ~w(json)],
  pubsub: [name: RecommendationsEx.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"