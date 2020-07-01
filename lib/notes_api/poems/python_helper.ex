defmodule NotesAPI.Poems.PythonHelper do
  def pypid(path) when is_list(path) do
    {:ok, pid} = :python.start([{:python_path, to_charlist(path)}])
    pid
  end

  def call(pid, module, function, args \\ []) do
    pid
    |> :python.call(module, function, args)
  end

  def stop(pid) do
    pid
    |> :python.stop()
  end
end
