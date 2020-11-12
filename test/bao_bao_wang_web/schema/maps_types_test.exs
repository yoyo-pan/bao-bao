defmodule BaoBaoWangWeb.Schema.MapsTypesTest do
  use BaoBaoWangWeb.ConnCase, async: true

  import BaoBaoWang.Factory

  describe "map query" do
    test "returns game map with given id", %{conn: conn} do
      game_map = insert(:game_map) |> with_map_tiles() |> with_map_objects()

      query = """
      {
        map(id: #{game_map.id}) {
          name
          width
          height
          tiles
          objects {
            objectId
            x
            y
          }
        }
      }
      """

      res = post_query(conn, query)

      assert res == %{
               "data" => %{
                 "map" => %{
                   "name" => "Village 10",
                   "width" => 2,
                   "height" => 2,
                   "tiles" => [1, 1, 2, 1],
                   "objects" => [
                     %{"objectId" => 1, "x" => 0, "y" => 0},
                     %{"objectId" => 1, "x" => 0, "y" => 1}
                   ]
                 }
               }
             }
    end
  end
end
