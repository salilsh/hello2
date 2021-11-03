defmodule Hello2.Repo.Migration do
  def run(_) do
    Application.put_env(:hello2, :enabled_workers, [])
    Application.ensure_all_started(:hello2)
    {EctoXandra, %{pid: conn}} = Ecto.Repo.Registry.lookup(Hello2.Repo)

    statements()
    |> Enum.each(&EctoXandra.Connection.execute(conn, &1, [], []))
  end

  defp statements() do
    keyspace = Application.get_env(:hello2, Hello2.Repo) |> Keyword.fetch!(:keyspace)

    [
      """
      CREATE KEYSPACE IF NOT EXISTS #{keyspace}
      WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'}
      AND durable_writes = true;
      """,
      """
      CREATE TABLE IF NOT EXISTS #{keyspace}.posts (
          id int,
          type text,
          title text,
          PRIMARY KEY ((type), id)
      );
      """
    ]
  end
end
