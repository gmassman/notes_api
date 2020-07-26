defmodule NotesAPI.Poems.PeriodicChecker do
  #@work_interval 100 * 60 * 60 * 1000
  @work_interval 60 * 60 * 1000 # 1 hour

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    next_state = NotesAPI.Poems.Publisher.run(state)
    schedule_work()
    {:noreply, next_state}
  end

  def schedule_work() do
    Process.send_after(self(), :work, @work_interval)
  end
end
