defmodule NotesAPI.Poems.Infosite do
  @infosite_repo Application.get_env(:notes_api, :infosite_repo)

  require Logger
  require IEx
  def publish(poem) do
    
    git_repo()
    |> Git.pull(~w(--rebase upstream master))

    
    #|> add_upstream()
    #|> 
    #|> Git.pull(~w(--rebase upstream master))

    IEx.pry
    nil
  end

  defp git_repo() do
    case Git.clone(@infosite_repo) do
      {:ok, repo} -> repo
      {:error, error} ->
        Logger.warn("clone infosite failed: #{error.message}")
        struct(Git.Repository, path: File.cwd! |> Path.join("infosite"))
    end
  end

  defp set_public_remote() do
    # setup GitHub remote for pushing public folder to gmassman.github.io
  end

  defp generate_poem(title, enml_content) do
    # run infosite/scripts/enml_to_mdx_poem.py <(echo #{enml_content}) > poem_content
    # also decide on whether python or elixir fills in the content/poetry/template.md file
    # Also make sure to use correct N prefix for poem, and correct title
  end
end
