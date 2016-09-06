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

  def upcase_table({type, %Table{} = table, columns}) do
    table = case Map.get(table, :prefix) do
              nil -> %{table | prefix: "APP"}
              _ -> table
            end
    table = %{table | name: String.upcase to_string table.name}
    table = %{table | prefix: String.upcase table.prefix}
    {type, table, columns}
  end

  def execute_ddl(repo, definition, opts) do
    definition = upcase_table(definition)
    case definition do
      {:create_if_not_exists, %Table{} = table, columns} ->
        sql = "SELECT tablename " <>
          "FROM sys.systables " <>
          "WHERE TABLESCHEMANAME = '#{table.prefix}' and TABLENAME = '#{table.name}'"
        unless if_table_exists(Ecto.Adapters.SQL.query!(repo, sql, [], opts)) do
          sql = @conn.execute_ddl(definition)
          IO.inspect sql
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
