defmodule BrothTest.Room.GetUsersTest do
  use ExUnit.Case, async: true
  use KousaTest.Support.EctoSandbox

  alias Beef.Schemas.User
  alias Beef.Users
  alias BrothTest.WsClient
  alias BrothTest.WsClientFactory
  alias KousaTest.Support.Factory

  require WsClient

  setup do
    user = Factory.create(User)
    client_ws = WsClientFactory.create_client_for(user)

    {:ok, user: user, client_ws: client_ws}
  end

  describe "the websocket room:get_banned_users operation" do
    test "returns one banned user if you are in the room", t do
      user_id = t.user.id
      # first, create a room owned by the primary user.
      {:ok, %{room: %{id: room_id}}} = Kousa.Room.create_room(user_id, "foo room", "foo", false)
      # make sure the user is in there.
      assert %{currentRoomId: ^room_id} = Users.get_by_id(user_id)

      # make user to ban and put them in the room
      user_to_ban = Factory.create(User)
      Kousa.Room.join_room(user_to_ban.id, room_id)
      # make sure the user is in there.
      assert %{currentRoomId: ^room_id} = Users.get_by_id(user_to_ban.id)
      Kousa.Room.block_from_room(user_id, user_to_ban.id)

      ref =
        WsClient.send_call(
          t.client_ws,
          "room:get_banned_users",
          %{}
        )

      banned_user_id = user_to_ban.id

      WsClient.assert_reply(
        "room:get_banned_users:reply",
        ref,
        %{
          "users" => [%{"id" => ^banned_user_id}]
        },
        t.client_ws
      )
    end

    test "returns what if you're not in a room", t do
      ref =
        WsClient.send_call(
          t.client_ws,
          "room:get_banned_users",
          %{}
        )

      WsClient.assert_reply(
        "room:get_banned_users:reply",
        ref,
        %{"users" => []},
        t.client_ws
      )
    end
  end
end
