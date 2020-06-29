defmodule NotesAPI.Poems.Infosite do
  @infosite_repo Application.get_env(:notes_api, :infosite_repo)
  @public_repo Application.get_env(:notes_api, :public_repo)

  require Logger
  require IEx
  def publish(poem) do
    
    repo = infosite_repo()
    repo |> Git.pull!(~w(--rebase origin master))
    #repo |> Git.rm!(~w(--cached public))
    #repo |> Git.submodule!(~w(add #{@public_repo} public))

    IEx.pry
    nil
  end

  defp infosite_repo() do
    case Git.clone(@infosite_repo) do
      {:ok, repo} -> repo
      {:error, error} ->
        Logger.warn("clone infosite failed: #{error.message}")
        struct(Git.Repository, path: File.cwd! |> Path.join("infosite"))
    end
  end

  #defp generate_poem(title, enml_content) do
    # run infosite/scripts/enml_to_mdx_poem.py <(echo #{enml_content}) > poem_content
    # also decide on whether python or elixir fills in the content/poetry/template.md file
    # Also make sure to use correct N prefix for poem, and correct title
  #end
end
