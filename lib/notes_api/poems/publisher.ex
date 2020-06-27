defmodule NotesAPI.Poems.Publisher do
  @en_access_token Application.get_env(:notes_api, :en_access_token)
  @publish_poem_tag "infosite:publish"

  require Logger

  def run(state) do
    Logger.info("current state: #{inspect(state)}")
    {:ok, client} = Everex.Client.new(@en_access_token)
    poems = client
            |> find_publish_tag()
            |> find_tagged_notes(client)
            |> fetch_note_contents(client)

    Logger.info("fetched notes: #{inspect(poems)}")

    new_state = Enum.reduce(poems, state, fn (poem, s) ->
      case NotesAPI.Poems.Infosite.publish(poem) do
        :ok -> put_in(s, [poem.guid], DateTime.utc_now())
        _ -> s
      end
    end)

    Logger.info(inspect(new_state))

    state
  end

  defp find_publish_tag(client) do
    case Everex.NoteStore.list_tags(client) do
      {:ok, tags} -> Enum.find(tags, &(&1.name == @publish_poem_tag))
      error -> error
    end
  end

  defp find_tagged_notes(nil, _client), do: nil
  defp find_tagged_notes(publish_tag, client) do
    tag_filter = %Everex.Types.NoteFilter{tagGuids: [publish_tag.guid]}
    case Everex.NoteStore.find_notes_metadata(client, tag_filter) do
      {:ok, tagged_notes} -> tagged_notes
      error -> error
    end
  end

  defp fetch_note_contents(nil, _client), do: []
  defp fetch_note_contents(tagged_notes, client) do
    tagged_notes.notes
    |> Enum.map(&(&1.guid))
    |> Enum.reduce([], fn (guid, acc) ->
      case Everex.NoteStore.get_note(client, guid, includeContent: true) do
        {:ok, note} -> [note | acc]
        error -> [error | acc]
      end
    end)
  end
end
