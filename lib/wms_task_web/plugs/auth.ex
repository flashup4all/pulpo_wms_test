defmodule WmsTaskWeb.Plugs.Auth do
  import Plug.Conn


  def init(opts), do: opts

  def call(conn, opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization") do
      conn
      |> assign(:auth_token, token)
    else
      error ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.put_view(WmsTaskWeb.ErrorView)
        |> Phoenix.Controller.render("401.json")
        |> halt()
    end
  end

end
