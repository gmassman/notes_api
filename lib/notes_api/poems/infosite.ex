defmodule NotesAPI.Poems.Infosite do
  @infosite_repo Application.get_env(:notes_api, :infosite_repo)

  require Logger

  def publish(poem) do
    repo = infosite_repo()
    repo |> Git.pull!(~w(--rebase origin master))
    repo |> Git.submodule!(~w(update --init))  # in case clone failed

    Logger.info("successfully cloned infosite")

    File.cd!("infosite", fn ->
      generate_poem!(poem.title, poem.content)
      build_and_deploy!()
      push_to_origin!(repo, poem.title)
    end)

    :ok
  end

  defp infosite_repo() do
    case Git.clone(~w(#{@infosite_repo} --recurse-submodules)) do
      {:ok, repo} -> repo
      {:error, error} ->
        Logger.warn("clone infosite failed: #{error.message}")
        struct(Git.Repository, path: File.cwd! |> Path.join("infosite"))
    end
  end

  defp generate_poem!(title, content) do
    tempfile = System.tmp_dir!() |> Path.join("note.enml")
    File.write!(tempfile, content)

    {res, code} = File.cwd!
                  |> Path.join("bin/enml_to_mdx_poem")
                  |> System.cmd([tempfile], stderr_to_stdout: true)

    if code != 0 do
      raise "failed to generate markdown poem: $? = #{code}\n#{res}"
    end

    File.rm!(tempfile)

    File.cwd!
    |> Path.join("src/content/poetry/#{next_poetry_filename(title)}")
    |> File.write!(poem_header(title) <> "\n" <> res)

    Logger.info("Generated poem file \"#{title}\"")
  end

  defp next_poetry_filename(title) do
    prev_max = File.cwd!
               |> Path.join("src/content/poetry")
               |> File.ls!
               |> Enum.map(fn file ->
                 String.split(file, "-")
                 |> hd
                 |> String.to_integer
               end)
               |> Enum.max
    formatted_title = title
                      |> String.downcase
                      |> String.split(" ")
                      |> Enum.join("-")
    "#{prev_max+1}-#{formatted_title}.md"
  end

  defp poem_header(title) do
    """
    ---
    title: "#{title}"
    date: #{Date.to_string(Date.utc_today)}
    description: "generated using NotesAPI"
    type: "poetry"
    ---
    """
  end

  defp build_and_deploy!() do
    {_res, code} = File.cwd!
                   |> Path.join("bin/deploy")
                   |> System.cmd([], stderr_to_stdout: true, into: IO.stream(:stdio, :line))
    if code != 0 do
      raise "failed to build and deploy: $? = #{code}"
    end

    Logger.info("built and deployed site")
  end

  defp push_to_origin!(repo, title) do
    repo |> Git.add!(".")
    repo |> Git.commit!(["-m", "published poetry: #{title}"])
    repo |> Git.push!()

    Logger.info("pushed new content to repo")
  end
end
