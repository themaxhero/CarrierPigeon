defmodule CarrierPigeon.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :user_id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :username, :string, null: false
      add :password, :string, null: false
      add :email, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:username])
    create unique_index(:users, [:email])

    create table(:profiles) do
      add :profile_id, :binary_id, primary_key: true
      add :nickname, :string, null: false
      add :avatar, :string, null: false
      add :owner_id, references(:users), null: false

      timestamps()
    end

    execute "CREATE TYPE room_type AS ENUM ('pm', 'group')"

    create table(:rooms) do
      add :room_id, :binary_id, primary_key: true
      add :name, :string
      add :photo, :string
      add :type, :room_type, null: false
      add :profile_id, references(:profiles)

      timestamps()
    end

    create table(:room_members) do
      add :room_member_id, :binary_id, primary_key: true
      add :room_id, references(:rooms), null: false
      add :profile_id, references(:profiles), null: false

      timestamps()
    end
    create unique_index(:room_members, [:room_id, :profile_id])

    create table(:room_messages) do
      add :msg_id, :binary_id, primary_key: true
      add :content, :string, null: false
      add :room_id, references(:rooms), null: false
      add :sender_id, references(:profiles), null: false

      timestamps()
    end
  end
end
