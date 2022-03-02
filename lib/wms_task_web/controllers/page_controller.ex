defmodule WmsTaskWeb.PageController do
  use WmsTaskWeb, :controller

  alias WmsTask.HttpHandler
  require Logger

  alias WmsTask.Orders
  alias WmsTask.Orders.Order

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def get_headers(user) do
    # TODO do we need both headers?
    {:ok, response} =
      HttpHandler.api_call("/api/v1/auth", :post, %{
        "username" => user,
        "password" => user,
        "grant_type" => "password",
        "scope" => "profile"
      })

    token = response.body["access_token"]
    headers = [Authorization: "Bearer #{token}"]
    headers
  end

  def get_orders_live(conn, params) do
    user = "felipe_user1"
    orders = get_orders_in_interval(user)
    render(conn, "orders.json", orders: %{"sales_orders" => orders})
  end

  defp get_orders_in_interval(user, interval \\ nil) do
    between =
      case interval do
        nil ->
          ""

        interval ->
          to = DateTime.utc_now()
          from = DateTime.add(to, -300_000, :second)
          "?updated_at=between:#{DateTime.to_iso8601(from)},#{DateTime.to_iso8601(to)}"
      end

    headers = get_headers(user)

    {:ok, response} = HttpHandler.api_call("/api/v1/sales/orders#{between}", :get, nil, headers)
    orders = response.body

    orders2 =
      Enum.map(
        orders["sales_orders"],
        fn order ->
          # order["order_num"]
          order_num = 1
          ## ?__or_search=sales_order_num%7Ccontains%3A#{order_num}&limit=20
          {:ok, pickings} =
            HttpHandler.api_call(
              "/api/v1/picking/orders?__or_search=sales_order_num%7Ccontains%3A#{order_num}&limit=20",
              :get,
              nil,
              headers
            )

          [picking | _] = pickings.body["picking_orders"]
          Map.put(order, "picking", picking)
        end
      )

    packings = WmsTask.get_packings(user, orders2)

    orders = WmsTask.map_packings(orders2, packings)
    create_orders(orders)
    orders
  end

  def get_orders(conn, params) do
    orders = Orders.list_orders()
    render(conn, "orders_model.json", orders: orders)
  end

  def sync_orders(interval \\ 1) do
    user = "felipe_user1"
    orders = get_orders_in_interval(user, interval)
    orders = WmsTask.map_to_order_model(orders)

    Logger.info("writing #{inspect(length(orders))} orders to the DB")
  end

  def create_orders(orders) do
    Enum.map(
      orders,
      &Orders.create_order(
        &1
        |> Map.put("order_updated", &1["updated_at"])
        |> Map.put("packing", Atom.to_string(&1["packing"]))
      )
    )
  end
end
