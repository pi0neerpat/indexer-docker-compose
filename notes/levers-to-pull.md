It will likely become important to manage/throttle your query service in order to stay competitive.

Keep in mind that the service you provide must match developer expectations. Otherwise they will build a buautiful query, but be frustrated when your service will not execute it.

### Throttling with query node Env Variables

- SUBSCRIPTION_THROTTLE_INTERVAL: while a subgraph is syncing, subscriptions to that subgraph get updated at most this often, in ms. Default is 1000ms.

  - No one has built a dapp that needs this responsiveness. Increase it!

- GRAPH_GRAPHQL_MAX_COMPLEXITY: maximum complexity for a graphql query. See here for what that means. Default is unlimited. Typical introspection queries have a complexity of just over 1 million, so setting a value below that may interfere with introspection done by graphql clients.

  - Reduce me!

- GRAPH_GRAPHQL_MAX_DEPTH: maximum depth of a graphql query. Default (and maximum) is 255.

  - Definitely want to reduce this one

- GRAPH_GRAPHQL_MAX_FIRST: maximum value that can be used for the first argument in GraphQL queries. If not provided, first defaults to 100. The default value for GRAPH_GRAPHQL_MAX_FIRST is 1000.

  - Yeah... you're not gonna show 1000 of anything on a screen. Reduce this!

## Throttling with
