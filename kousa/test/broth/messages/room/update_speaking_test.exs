defmodule BrothTest.Message.Room.UpdateSpeakingTest do
  use ExUnit.Case, async: true

  alias Broth.Message.Room.UpdateSpeaking

  describe "when you send an invite message" do
    test "it populates isSpeaking" do
      assert {:ok,
              %{
                payload: %UpdateSpeaking{isSpeaking: true}
              }} =
               Broth.Message.validate(%{
                 "operator" => "room:update_speaking",
                 "payload" => %{"isSpeaking" => true}
               })

      # short form also allowed
      assert {:ok,
              %{
                payload: %UpdateSpeaking{isSpeaking: true}
              }} =
               Broth.Message.validate(%{
                 "op" => "room:update_speaking",
                 "p" => %{"isSpeaking" => true}
               })
    end

    test "omitting the isSpeaking parameter is not allowed" do
      assert {:error, %{errors: [isSpeaking: {"can't be blank", _}]}} =
               Broth.Message.validate(%{
                 "operator" => "room:update_speaking",
                 "payload" => %{}
               })
    end
  end
end
