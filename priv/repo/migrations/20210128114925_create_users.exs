defmodule CarrierPigeon.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :user_id, :uuid,
        primary_key: true

      add :name, :string,
        null: false

      add :username, :string,
        null: false

      add :password, :string,
        null: false

      add :email, :string,
        null: false

      timestamps()
    end

    create unique_index(:users, [:username])
    create unique_index(:users, [:email])

    create table(:profiles, primary_key: false) do
      add :profile_id, :uuid,
        primary_key: true

      add :nickname, :string, null: false
      add :avatar, :string

      add :user_id,
        references(:users, column: :user_id, type: :uuid),
        null: false

      timestamps()
    end

    execute "CREATE TYPE room_type AS ENUM ('pm', 'group')"

    create table(:rooms, primary_key: false) do
      add :room_id, :uuid,
        primary_key: true

      add :name, :string,
        null: true
      add :photo, :string,
        null: true

      add :type, :room_type,
        null: false

      add :profile_id,
        references(:profiles, column: :profile_id, type: :uuid)

      timestamps()
    end

    create table(:room_members, primary_key: false) do
      add :room_member_id, :uuid,
        primary_key: true

      add :room_id,
        references(:rooms, column: :room_id, type: :uuid, on_delete: :delete_all),
        null: false,
        on_delete: :delete_all

      add :profile_id,
        references(:profiles, column: :profile_id, type: :uuid, on_delete: :delete_all),
        null: false

      timestamps()
    end
    create unique_index(:room_members, [:room_id, :profile_id])

    create table(:room_messages, primary_key: false) do
      add :msg_id, :uuid,
        primary_key: true

      add :content, :string, null: false

      add :room_id,
        references(:rooms, column: :room_id, type: :uuid),
        null: false

      add :sender_id,
        references(:profiles, column: :profile_id, type: :uuid),
        null: false

      timestamps()
    end
  end
end
