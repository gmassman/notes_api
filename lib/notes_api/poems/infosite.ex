defmodule NotesAPI.Poems.Infosite do
  @infosite_repo Application.get_env(:notes_api, :infosite_repo)

  alias NotesAPI.Poems.PythonHelper
  require Logger
  require IEx
  def publish(poem) do
    
    repo = infosite_repo()
    repo |> Git.pull!(~w(--rebase origin master))

    Logger.info("successfully cloned infosite")

    File.cd!("infosite", fn ->
      generate_poem(poem.title, poem.content)
    end)

    nil
  end

  defp infosite_repo() do
    case Git.clone(~w(#{@infosite_repo} --recurse-submodules)) do
      {:ok, repo} -> repo
      {:error, error} ->
        Logger.warn("clone infosite failed: #{error.message}")
        struct(Git.Repository, path: File.cwd! |> Path.join("infosite"))
    end
  end

  def generate_poem(title, content) do
    {res0, code0} = File.cwd!
                    |> Path.join("scripts/bootstrap_python.sh")
                    |> System.cmd([])
    Logger.info("Installed python deps: status #{code0}")

    {res1, code1} = System.cmd("poetry", ["shell"])
    Logger.info("Activate python 3.7: status #{code1}")

    {res2, code2} = File.cwd!
                    |> Path.join("scripts/enml_to_mdx_poem.py")
                    |> System.cmd([])
    Logger.info("Ran ENML -> MDX script: status #{code2}")

    #content = format_poem(title, content)
    IEx.pry
    res2
  end

  def next_poetry_filename(title) do
    prev_max = "infosite/content/poetry"
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

  #def format_poem(title, enml_content) do
    #pypid = PythonHelper.pypid('scripts')

    #md_content = pypid
                 #|> PythonHelper.call(:enml_to_mdx_poem, :generate_markdown, [enml_content])
                 #|> to_string()

    #IEx.pry
    #PythonHelper.stop(pypid)
    #md_content
  #end
  #defp generate_poem(title, enml_content) do
    # run infosite/scripts/enml_to_mdx_poem.py <(echo #{enml_content}) > poem_content
    # also decide on whether python or elixir fills in the content/poetry/template.md file
    # Also make sure to use correct N prefix for poem, and correct title
  #end
end
