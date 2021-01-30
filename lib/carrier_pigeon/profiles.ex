defmodule CarrierPigeon.Profiles do
  alias CarrierPigeon.Repo
  alias CarrierPigeon.Profiles.Profile

  @type create_profile_params :: Profile.creation_attrs()

  @spec create_profile(create_profile_params) ::
    { :ok, Profile.t() }
    | { :error, atom() }
  def create_profile(attrs) do
    %Profile{}
    |> Profile.changeset(attrs)
    |> Repo.insert
  end

  def get_profile(profile_id),
    do: Repo.get(Profile, profile_id)

  def get_profile!(profile_id),
    do: Repo.get!(Profile, profile_id)
end
