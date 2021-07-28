defmodule NflWeb.PlayerLive do
  use NflWeb, :live_view

  alias Nfl.Players

  def mount(params, _session, socket) do
    {:ok, prepare_socket(params, socket)}
  end

  def handle_params(params, _url, socket) do
    {:noreply, prepare_socket(params, socket)}
  end

  def handle_event("search-player", %{"name" => name}, socket) do
    result = Players.search_players_by_name(name)

    socket =
      assign(socket,
        players: result["players"],
        current_page: result["current_page"],
        per_page: result["per_page"],
        next_page: result["current_page"] + 1,
        previous_page: result["current_page"] - 1,
        sort_by: result["sort_by"],
        order_by: result["order_by"],
        name: name
      )

    {:noreply, socket}
  end

  defp prepare_socket(params, socket) do
    filters = Map.take(params, ~w(current_page per_page sort_by order_by))

    result = Players.list_players(filters)

    assign(socket,
      players: result["players"],
      current_page: result["current_page"],
      per_page: result["per_page"],
      next_page: result["current_page"] + 1,
      previous_page: result["current_page"] - 1,
      sort_by: result["sort_by"],
      order_by: result["order_by"],
      name: ""
    )
  end

  defp pagination_link(socket, text, current_page, per_page, sort_by, order_by) do
    live_patch(text,
      to:
        Routes.live_path(
          socket,
          __MODULE__,
          current_page: current_page,
          per_page: per_page,
          sort_by: sort_by,
          order_by: order_by
        )
    )
  end

  defp sort_link(socket, sort_by, order_by, current_page, per_page) do
    order_by = if order_by == "asc", do: "desc", else: "asc"

    live_patch(sort_by,
      to:
        Routes.live_path(
          socket,
          __MODULE__,
          current_page: current_page,
          per_page: per_page,
          sort_by: sort_by,
          order_by: order_by
        )
    )
  end
end
