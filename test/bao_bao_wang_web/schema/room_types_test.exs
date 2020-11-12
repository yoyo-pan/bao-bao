defmodule BaoBaoWangWeb.Schema.RoomTypesTest do
  use BaoBaoWangWeb.ConnCase

  import Absinthe.Relay.Node, only: [to_global_id: 2, to_global_id: 3]
  import BaoBaoWang.Factory

  alias BaoBaoWang.Room
  alias BaoBaoWangWeb.Schema

  setup do
    Room.reset()
  end

  describe "room query" do
    defp query(:room, room_id) do
      """
      {
        room(id: #{room_id}) {
          idNumber
          host {
            nickname
          }
          players {
            user {
              nickname
            }
            isReady
          }
        }
      }
      """
    end

    test "returns the room", %{conn: conn} do
      user = insert(:user)
      {:ok, room} = Room.create(user.id)

      res = post_query(conn, query(:room, room.id))

      assert res == %{
               "data" => %{
                 "room" => %{
                   "idNumber" => 1,
                   "players" => [%{"user" => %{"nickname" => user.nickname}, "isReady" => false}],
                   "host" => %{"nickname" => user.nickname}
                 }
               }
             }
    end

    test "returns error if the room is not exist", %{conn: conn} do
      res = post_query(conn, query(:room, 1))

      assert %{"data" => nil, "errors" => errors} = res
      assert [%{"message" => "room_is_not_found"}] = errors
    end
  end

  describe "rooms query" do
    test "returns rooms", %{conn: conn} do
      user = insert(:user)
      Room.create(user.id)

      query = """
      {
        rooms {
          idNumber
          host {
            nickname
          }
          players {
            id
            user {
              nickname
            }
          }
        }
      }
      """

      res = post_query(conn, query)

      assert res == %{
               "data" => %{
                 "rooms" => [
                   %{
                     "idNumber" => 1,
                     "players" => [
                       %{
                         "id" => to_global_id(:room_player, user.id, Schema),
                         "user" => %{"nickname" => user.nickname}
                       }
                     ],
                     "host" => %{"nickname" => user.nickname}
                   }
                 ]
               }
             }
    end
  end

  describe "create_room mutation" do
    @query """
    mutation {
      createRoom {
        result {
          idNumber
          host {
            nickname
          }
          players {
            user {
              nickname
            }
          }
        }
        successful
        messages {
          message
        }
      }
    }
    """

    test "creates a room", %{conn: conn} do
      user = insert(:user)
      res = post_query(conn, @query, current_user: user)

      assert res == %{
               "data" => %{
                 "createRoom" => %{
                   "result" => %{
                     "idNumber" => 1,
                     "players" => [%{"user" => %{"nickname" => "nickname"}}],
                     "host" => %{"nickname" => "nickname"}
                   },
                   "successful" => true,
                   "messages" => []
                 }
               }
             }
    end

    test "fails if the user is already in the room", %{conn: conn} do
      [user, another_user] = insert_list(2, :user)
      {:ok, room} = Room.create(another_user.id)
      Room.join(user.id, room.id)

      res = post_query(conn, @query, current_user: user)

      assert res == %{
               "data" => %{
                 "createRoom" => %{
                   "result" => nil,
                   "successful" => false,
                   "messages" => [%{"message" => "user_is_joined"}]
                 }
               }
             }
    end
  end

  describe "join_room mutation" do
    defp query(:join_room, room_id) do
      """
      mutation {
        joinRoom(roomId: #{room_id}) {
          result {
            idNumber
            host {
              nickname
            }
            players {
              user {
                nickname
              }
            }
          }
          successful
          messages {
            message
          }
        }
      }
      """
    end

    test "joins to the room", %{conn: conn} do
      host_user = insert(:user, nickname: "host")
      user = insert(:user)
      {:ok, room} = Room.create(host_user.id)

      res = post_query(conn, query(:join_room, room.id), current_user: user)

      assert res == %{
               "data" => %{
                 "joinRoom" => %{
                   "result" => %{
                     "idNumber" => room.id,
                     "players" => [
                       %{"user" => %{"nickname" => user.nickname}},
                       %{"user" => %{"nickname" => host_user.nickname}}
                     ],
                     "host" => %{"nickname" => host_user.nickname}
                   },
                   "successful" => true,
                   "messages" => []
                 }
               }
             }
    end

    test "fails if the user is already in the room", %{conn: conn} do
      user = insert(:user)
      {:ok, room} = Room.create(user.id)
      Room.join(user.id, room.id)

      res = post_query(conn, query(:join_room, room.id), current_user: user)

      assert res == %{
               "data" => %{
                 "joinRoom" => %{
                   "result" => nil,
                   "successful" => false,
                   "messages" => [%{"message" => "user_is_joined"}]
                 }
               }
             }
    end

    test "fails if the room is full", %{conn: conn} do
      host_user = insert(:user)
      user = insert(:user)

      {:ok, room} = Room.create(host_user.id)

      insert_list(7, :user)
      |> Enum.each(&Room.join(&1.id, room.id))

      res = post_query(conn, query(:join_room, room.id), current_user: user)

      assert res == %{
               "data" => %{
                 "joinRoom" => %{
                   "result" => nil,
                   "successful" => false,
                   "messages" => [%{"message" => "room_is_full"}]
                 }
               }
             }
    end

    test "fails if the room is not exist", %{conn: conn} do
      user = insert(:user)

      res = post_query(conn, query(:join_room, 0), current_user: user)

      assert res == %{
               "data" => %{
                 "joinRoom" => %{
                   "result" => nil,
                   "successful" => false,
                   "messages" => [%{"message" => "room_is_not_found"}]
                 }
               }
             }
    end
  end

  describe "leave_room mutation" do
    @query """
    mutation {
      leaveRoom {
        result {
          idNumber
          host {
            nickname
          }
          players {
            user {
              nickname
            }
          }
        }
        successful
        messages {
          message
        }
      }
    }
    """

    test "leaves a room", %{conn: conn} do
      user = insert(:user)
      guest_user = insert(:user, nickname: "guest")
      {:ok, room} = Room.create(user.id)
      Room.join(guest_user.id, room.id)

      res = post_query(conn, @query, current_user: user)

      assert res == %{
               "data" => %{
                 "leaveRoom" => %{
                   "result" => %{
                     "idNumber" => room.id,
                     "players" => [
                       %{"user" => %{"nickname" => guest_user.nickname}}
                     ],
                     "host" => %{"nickname" => guest_user.nickname}
                   },
                   "successful" => true,
                   "messages" => []
                 }
               }
             }
    end

    test "leaves and closes the room if the room empty", %{conn: conn} do
      user = insert(:user)
      {:ok, room} = Room.create(user.id)

      res = post_query(conn, @query, current_user: user)

      assert res == %{
               "data" => %{
                 "leaveRoom" => %{
                   "result" => %{
                     "idNumber" => room.id,
                     "players" => [],
                     "host" => nil
                   },
                   "successful" => true,
                   "messages" => []
                 }
               }
             }
    end

    test "fails if the user is not in any room", %{conn: conn} do
      user = insert(:user)
      res = post_query(conn, @query, current_user: user)

      assert res == %{
               "data" => %{
                 "leaveRoom" => %{
                   "result" => nil,
                   "successful" => false,
                   "messages" => [%{"message" => "user_is_not_joined"}]
                 }
               }
             }
    end
  end

  describe "kick_player mutation" do
    defp query(:kick_player, user_id) do
      user_global_id = to_global_id("User", user_id)

      """
      mutation {
        kickPlayer(userId: "#{user_global_id}") {
          result {
            idNumber
            host {
              nickname
            }
            players {
              user {
                nickname
              }
            }
          }
          successful
          messages {
            message
          }
        }
      }
      """
    end

    test "kicks player from the room", %{conn: conn} do
      host_user = insert(:user, nickname: "host")
      guest_user = insert(:user)

      {:ok, room} = Room.create(host_user.id)
      Room.join(guest_user.id, room.id)

      res = post_query(conn, query(:kick_player, guest_user.id), current_user: host_user)

      assert res == %{
               "data" => %{
                 "kickPlayer" => %{
                   "result" => %{
                     "idNumber" => room.id,
                     "players" => [%{"user" => %{"nickname" => host_user.nickname}}],
                     "host" => %{"nickname" => host_user.nickname}
                   },
                   "successful" => true,
                   "messages" => []
                 }
               }
             }
    end

    test "fails if the current user is not the host", %{conn: conn} do
      host_user = insert(:user, nickname: "host")
      guest_user = insert(:user)

      {:ok, room} = Room.create(host_user.id)
      Room.join(guest_user.id, room.id)

      res = post_query(conn, query(:kick_player, host_user.id), current_user: guest_user)

      assert res == %{
               "data" => %{
                 "kickPlayer" => %{
                   "result" => nil,
                   "successful" => false,
                   "messages" => [%{"message" => "user_is_not_host"}]
                 }
               }
             }
    end

    test "fails if the current user is himself", %{conn: conn} do
      user = insert(:user, nickname: "host")
      Room.create(user.id)
      res = post_query(conn, query(:kick_player, user.id), current_user: user)

      assert res == %{
               "data" => %{
                 "kickPlayer" => %{
                   "result" => nil,
                   "successful" => false,
                   "messages" => [%{"message" => "cannot_kick_yourself"}]
                 }
               }
             }
    end

    test "fails if the current user is not in any room", %{conn: conn} do
      user = insert(:user, nickname: "host")
      res = post_query(conn, query(:kick_player, 0), current_user: user)

      assert res == %{
               "data" => %{
                 "kickPlayer" => %{
                   "result" => nil,
                   "successful" => false,
                   "messages" => [%{"message" => "user_is_not_joined"}]
                 }
               }
             }
    end
  end

  describe "ready mutation" do
    @query """
    mutation {
      ready {
        result {
          players {
            user {
              nickname
            }
            isReady
          }
        }
        successful
        messages {
          message
        }
      }
    }
    """

    test "turns on ready", %{conn: conn} do
      user = insert(:user)
      Room.create(user.id)

      res = post_query(conn, @query, current_user: user)

      assert res == %{
               "data" => %{
                 "ready" => %{
                   "result" => %{
                     "players" => [
                       %{"user" => %{"nickname" => user.nickname}, "isReady" => true}
                     ]
                   },
                   "successful" => true,
                   "messages" => []
                 }
               }
             }
    end

    test "fails if the user is not in any room", %{conn: conn} do
      user = insert(:user)
      res = post_query(conn, @query, current_user: user)

      assert res == %{
               "data" => %{
                 "ready" => %{
                   "result" => nil,
                   "successful" => false,
                   "messages" => [%{"message" => "user_is_not_joined"}]
                 }
               }
             }
    end
  end

  describe "unready mutation" do
    @query """
    mutation {
      unready {
        result {
          players {
            user {
              nickname
            }
            isReady
          }
        }
        successful
        messages {
          message
        }
      }
    }
    """

    test "turns off ready", %{conn: conn} do
      user = insert(:user)
      Room.create(user.id)

      res = post_query(conn, @query, current_user: user)

      assert res == %{
               "data" => %{
                 "unready" => %{
                   "result" => %{
                     "players" => [
                       %{"user" => %{"nickname" => user.nickname}, "isReady" => false}
                     ]
                   },
                   "successful" => true,
                   "messages" => []
                 }
               }
             }
    end

    test "fails if the user is not in any room", %{conn: conn} do
      user = insert(:user)
      res = post_query(conn, @query, current_user: user)

      assert res == %{
               "data" => %{
                 "unready" => %{
                   "result" => nil,
                   "successful" => false,
                   "messages" => [%{"message" => "user_is_not_joined"}]
                 }
               }
             }
    end
  end
end
