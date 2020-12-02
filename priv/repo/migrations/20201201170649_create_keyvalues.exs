defmodule LrucacheApi.Repo.Migrations.CreateKeyvalues do
  use Ecto.Migration

  def change do
    create table(:keyvalues) do
      add :key, :string
      add :value, :string

      timestamps()
    end

  end
end
