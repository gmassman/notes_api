defmodule NotesAPI.Poems.Publisher do
  @en_access_token Application.get_env(:notes_api, :en_access_token)
  @publish_poem_tag "infocyte:publish"

  require IEx

  def run(state) do
    IO.inspect(state, label: "current state")
    {:ok, client} = Everex.Client.new(@en_access_token)
    {:ok, tags} = client |> Everex.NoteStore.list_tags
    publish_tag = Enum.find(tags, &(&1.name == @publish_poem_tag))
    tag_filter = %Everex.Types.NoteFilter{tagGuids: [publish_tag.guid]}
    {:ok, tagged_notes} = client |> Everex.NoteStore.find_notes_metadata(tag_filter)
    {:ok, notes} = client |> Everex.NoteStore.get_note(Enum.map(tagged_notes.notes, &(&1.guid)), content: true)

    IEx.pry
    state
  end
end
