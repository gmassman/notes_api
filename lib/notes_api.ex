defmodule NotesAPI do
  @moduledoc """
  Documentation for `NotesAPI`.
  """

  def evernote_client do
    {:ok, client} = Everex.Client.new(System.get_env("EN_DEVELOPER_TOKEN"))
    client
    |> Everex.NoteStore.list_tags
    |> IO.inspect
  end

  @doc """
  Hello world.

  ## Examples

      iex> NotesAPI.hello()
      :world

  """
  def hello do
    :world
  end
end
