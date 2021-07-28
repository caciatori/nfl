defmodule NflWeb.PlayerController do
  use NflWeb, :controller

  alias Nfl.Players

  def export(conn, %{"name" => name}) do
    %{"players" => players} = Players.search_players_by_name(name)

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"players.csv\"")
    |> send_resp(200, Players.export_data_to_csv(players))
  end
end
