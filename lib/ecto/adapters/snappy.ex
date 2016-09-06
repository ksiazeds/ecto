defmodule Ecto.Adapters.SnappyData do
  @moduledoc """
  """

  # Inherit all behaviour from Ecto.Adapters.SQL
  use Ecto.Adapters.SQL, :snappyex

  # And provide a custom storage implementation
  #@behaviour Ecto.Adapter.Storage
  #@behaviour Ecto.Adapter.Structure

  @doc false
  def supports_ddl_transaction? do
    false
  end
  alias Ecto.Migration.{Table, Index, Reference, Constraint}
  @conn __MODULE__.Connection

  def execute_ddl(repo, definition, opts) do
     case definition do
       {:create_if_not_exists, %Table{} = table, columns} ->
         table = case Map.get(table, :prefix) do
           nil -> %{table | prefix: "APP"}
           _ -> table
                 end
         sql = "SELECT tablename " <>
           "FROM sys.systables " <>
           "WHERE TABLESCHEMANAME = '#{String.upcase table.prefix}' and TABLENAME = '#{String.upcase to_string table.name}'"
         IO.inspect sql
         unless if_table_exists(Ecto.Adapters.SQL.query!(repo, sql, [], opts)) do
         sql = @conn.execute_ddl(definition)
         Ecto.Adapters.SQL.query!(repo, sql, [], opts)
       end
     _ -> sql = @conn.execute_ddl(definition)
     Ecto.Adapters.SQL.query!(repo, sql, [], opts)
     :ok
     end
  end
  def if_table_exists([[table]]) do
    table
  end

  def if_table_exists([]) do
    nil
  end
end
