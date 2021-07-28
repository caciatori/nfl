defmodule Nfl.PlayersTest do
  use ExUnit.Case

  alias Nfl.Players

  describe "read_file/0" do
    test "it returns a list of map that represents a Player" do
      assert {:ok, players} = Players.read_file()

      assert length(players) == 326
    end
  end

  describe "list_players/1" do
    test "it without args returns a first page of list with 10 items" do
      assert %{
               "current_page" => 1,
               "per_page" => 10,
               "players" => players,
               "order_by" => "asc",
               "sort_by" => "Yds"
             } = Players.list_players()

      assert length(players) == 10
    end

    test "it with args returns related page of list with the number of items" do
      params = %{
        "current_page" => "3",
        "per_page" => "50",
        "sort_by" => "Yds",
        "order_by" => "asc"
      }

      assert %{"players" => players} = result = Players.list_players(params)

      assert result["current_page"] == 3
      assert result["per_page"] == 50
      assert length(players) == 50
    end
  end

  describe "search_players_by_name/1" do
    test "it returns matched players with the name passed as param" do
      param = "Eli"
      assert %{"players" => players} = Players.search_players_by_name(param)

      for %{"Player" => name} <- players do
        assert String.contains?(name, param)
      end
    end
  end

  describe "export_data_to_csv" do
    param = "Lewis"
    assert %{"players" => players} = Players.search_players_by_name(param)

    expected_csv_content = """
    1st,1st%,20+,40+,Att,Att/G,Avg,FUM,Lng,Player,Pos,TD,Team,Yds,Yds/G\r
    1,33.3,0,0,3,0.2,3.7,0,7,Tommylee Lewis,WR,0,NO,11,0.9\r
    14,21.9,0,0,64,9.1,4.4,1,15,Dion Lewis,RB,0,NE,283,40.4\r
    """

    assert expected_csv_content == Players.export_data_to_csv(players)
  end
end
