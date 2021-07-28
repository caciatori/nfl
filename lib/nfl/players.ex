defmodule Nfl.Players do
  @moduledoc """
  Module responsible for handle with Players data
  """

  @default_page "1"
  @default_page_size "10"
  @default_sort_by "Yds"
  @default_order_by "asc"

  @doc """
  It reads JSON data from an external file

  ## Examples

      iex> read_file()
      {:ok, [%{}]}
  """
  def read_file do
    file_path = Path.join(:code.priv_dir(:nfl), "data/rushing.json")

    with {:ok, content} <- File.read(file_path),
         {:ok, players} <- Jason.decode(content),
         do: {:ok, players}
  end

  @doc """
  It returns a tuple with a list of players and its related page

  ## Examples

      iex> list_players()
      %{
        "current_page" => 1,
        "players" => [],
        "per_page" => 10,
        "sort_by" => "Yds",
        "order_by" => "asc"
      }

      iex> list_players(%{"current_page" => 2,"per_page" => 5,"sort_by" => "TD","order_by" => "asc"})
      %{
        "current_page" => 2,
        "players" => [],
        "per_page" => 5,
        "sort_by" => "TD",
        "order_by" => "asc"
      }

  """
  def list_players(params \\ %{})

  def list_players(
        %{
          "current_page" => current_page,
          "per_page" => per_page,
          "sort_by" => sort_by,
          "order_by" => order_by
        } = params
      ) do
    with {:ok, players} <- read_file() do
      current_page = String.to_integer(current_page)
      per_page = String.to_integer(per_page)

      {players, _index} =
        players
        |> Enum.sort_by(fn player -> player[sort_by] end, String.to_atom(order_by))
        |> Enum.chunk_every(per_page)
        |> Enum.with_index()
        |> Enum.find(fn {_list, index} -> index == current_page - 1 end)

      params
      |> Map.put("players", players)
      |> Map.put("current_page", current_page)
      |> Map.put("per_page", per_page)
      |> Map.put("sort_by", sort_by)
      |> Map.put("order_by", order_by)
    end
  end

  def list_players(_) do
    list_players(%{
      "current_page" => @default_page,
      "per_page" => @default_page_size,
      "sort_by" => @default_sort_by,
      "order_by" => @default_order_by
    })
  end

  @doc """
  Search playbers by the name

  ## Examples

      iex> search_players_by_name("Eli")
      [%{}]

  """
  def search_players_by_name(name) do
    with {:ok, players} <- read_file() do
      players = Enum.filter(players, fn player -> String.contains?(player["Player"], name) end)

      %{
        "current_page" => String.to_integer(@default_page),
        "per_page" => @default_page_size,
        "sort_by" => @default_sort_by,
        "order_by" => @default_order_by,
        "players" => players
      }
    end
  end

  @doc """
  Export data to CSV with Players information

  ## Examples

      iex> export_data_to_csv([])
      ""

      iex> export_data_to_csv([...])
      "1st,1st%,20+,40+,Att,Att/G,Avg,FUM,Lng,Player,Pos,TD,Team,Yds,Yds/G..."

  """
  def export_data_to_csv(players) do
    players
    |> CSV.encode(headers: true)
    |> Enum.to_list()
    |> to_string()
  end
end
