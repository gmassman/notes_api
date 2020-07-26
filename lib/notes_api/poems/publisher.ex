defmodule NotesAPI.Poems.Publisher do
  @en_access_token Application.get_env(:notes_api, :en_access_token)
  @publish_poem_tag "infosite:poetry"

  require Logger

  def run(state) do
    Logger.info("current state: #{inspect(state)}")
    {:ok, client} = Everex.Client.new(@en_access_token)
    :timer.sleep(500)  # wait for the client GenServer to come online...
    poems = client
            |> find_publish_tag()
            |> find_tagged_notes(client)
            |> fetch_note_contents(client)

    Logger.info("fetched notes: #{inspect(poems)}")

    Enum.reduce(poems, state, fn (poem, s) ->
      :ok = NotesAPI.Poems.Infosite.publish(poem)
      replace_publish_tag(client, poem)
      put_in(s, [poem.guid], DateTime.utc_now())
    end)
  end

  defp find_publish_tag(client) do
    {:ok, tags} = Everex.NoteStore.list_tags(client)
    Enum.find(tags, &(&1.name == @publish_poem_tag))
  end

  defp find_tagged_notes(nil, _client), do: nil
  defp find_tagged_notes(publish_tag, client) do
    tag_filter = %Everex.Types.NoteFilter{tagGuids: [publish_tag.guid]}
    {:ok, tagged_notes} = Everex.NoteStore.find_notes_metadata(client, tag_filter)
    tagged_notes
  end

  defp fetch_note_contents(nil, _client), do: []
  defp fetch_note_contents(tagged_notes, client) do
    tagged_notes.notes
    |> Enum.map(&(&1.guid))
    |> Enum.reduce([], fn (guid, acc) ->
      {:ok, note} = Everex.NoteStore.get_note(client, guid, includeContent: true)
      [note | acc]
    end)
  end

  defp replace_publish_tag(client, poem) do
    pubtime = DateTime.utc_now
              |> DateTime.to_unix
              |> Integer.to_string
    {:ok, newtag} = client |> Everex.NoteStore.create_tag(name: "#{@publish_poem_tag}:published-#{pubtime}")
    {:ok, note} = client |> Everex.NoteStore.update_note(poem.guid, poem.title, tagGuids: [newtag.guid])

    Logger.info("replaced tag for poem #{note.title}")
  end
end
