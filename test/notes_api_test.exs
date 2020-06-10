defmodule NotesAPITest do
  use ExUnit.Case
  doctest NotesAPI

  test "greets the world" do
    assert NotesAPI.hello() == :world
  end
end
