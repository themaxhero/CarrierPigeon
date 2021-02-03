defmodule CarrierPigeon.Profiles do
  alias CarrierPigeon.Repo
  alias CarrierPigeon.Accounts.User
  alias CarrierPigeon.Profiles.Profile

  @type create_profile_params :: Profile.creation_attrs()

  @spec create_profile(User.t(), create_profile_params) ::
    { :ok, Profile.t() }
    | { :error, atom() }
  def create_profile(%User{} = user, attrs) do
    { :ok, profile } =
      user
      |> Ecto.build_assoc(:profiles)
      |> Profile.changeset(attrs)
      |> Repo.insert

    profile =
      profile
      |> Repo.preload(:user)
      |> Repo.preload(:rooms)

    { :ok, profile }
  end

  @spec create_profile!(User.t(), create_profile_params) :: Profile.t()
  def create_profile!(%User{} = user, attrs) do
    user
    |> Ecto.build_assoc(:profiles)
    |> Profile.changeset(attrs)
    |> Repo.insert!
    |> Repo.preload(:user)
    |> Repo.preload(:rooms)
  end

  @type update_profile_params :: Profile.update_attrs

  @spec update_profile(String.t(), update_profile_params) ::
    { :ok, Profile.t() }
    | { :error, atom() }
  def update_profile(profile_id, attrs) when is_binary(profile_id) do
    profile_id
    |> get_profile!
    |> Profile.changeset(attrs)
    |> Repo.update
  end

  @spec update_profile!(String.t(), update_profile_params) :: Profile.t()
  def update_profile!(profile_id, attrs) when is_binary(profile_id) do
    profile_id
    |> get_profile!
    |> Profile.changeset(attrs)
    |> Repo.update!
  end

  @spec delete_profile(String.t() | Profile.t()) ::
    { :ok, Profile.t() }
    | { :error, atom() }
  def delete_profile(%Profile{} = profile),
    do: Repo.delete(profile)
  def delete_profile(profile_id) when is_binary(profile_id) do
    profile_id
    |> get_profile!
    |> delete_profile
  end

  @spec delete_profile!(String.t() | Profile.t()) ::
    Profile.t()
  def delete_profile!(%Profile{} = profile),
    do: Repo.delete!(profile)
  def delete_profile!(profile_id) when is_binary(profile_id) do
    profile_id
    |> get_profile!
    |> delete_profile!
  end

  @spec get_profile(String.t()) ::
    { :ok, Profile.t() }
    | { :error, atom() }
  def get_profile(profile_id) when is_binary(profile_id) do
    case Repo.get(Profile, profile_id) do
      { :ok, %Profile{} = profile } ->
        profile =
          profile
          |> Repo.preload(:user)
          |> Repo.preload(:rooms)

        { :ok, profile }

      nil ->
        { :error, :internal }
    end
  end

  @spec get_profile!(String.t()) :: Profile.t()
  def get_profile!(profile_id) do
    Profile
    |> Repo.get!(profile_id)
    |> Repo.preload(:user)
    |> Repo.preload(:rooms)
  end
end
