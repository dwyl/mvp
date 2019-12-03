defmodule App.Ctx.Person do
  use Ecto.Schema
  import Ecto.Changeset

  schema "people" do
    field :email, Fields.EmailEncrypted
    field :email_hash, Fields.EmailHash
    field :familyName, :binary
    field :givenName, :binary
    field :locale, :string
    field :password, :string, virtual: true
    field :password_hash, :binary
    field :picture, :binary
    field :username, :binary
    field :username_hash, :binary
    field :status, :id
    field :tag, :id
    field :key_id, :integer

    has_many :sessions, App.Ctx.Session, on_delete: :delete_all
    timestamps()
  end

  @doc false
  def changeset(%{email: email} = person, attrs) do
    person
    |> cast(attrs, [:username, :email, :givenName, :familyName, :password_hash, :key_id, :locale, :picture])
    |> validate_required([:username, :email, :givenName, :familyName, :password_hash, :key_id])
    |> put_change(:email_hash, email )
  end

  def google_changeset(%{email: email} = profile, attrs) do
    profile
    |> cast(attrs, [:email, :givenName, :familyName, :picture, :locale])
    |> validate_required([:email])
    |> put_change(:email_hash, email )
  end

  @doc """
  `transform_profile_data_to_person/1` transforms the profile data
  received from invoking `ElixirAuthGoogle.get_user_profile/1`
  into a `person` record that can be inserted into the people table.

  ## Example

    iex> transform_profile_data_to_person(%{
      "email" => "nelson@gmail.com",
      "email_verified" => true,
      "family_name" => "Correia",
      "given_name" => "Nelson",
      "locale" => "en",
      "name" => "Nelson Correia",
      "picture" => "https://lh3.googleusercontent.com/a-/AAuE7mApnYb260YC1JY7a",
      "sub" => "940732358705212133793"
    })
    %{
      "email" => "nelson@gmail.com",
      "email_verified" => true,
      "family_name" => "Correia",
      "given_name" => "Nelson",
      "locale" => "en",
      "name" => "Nelson Correia",
      "picture" => "https://lh3.googleusercontent.com/a-/AAuE7mApnYb260YC1JY7a",
      "sub" => "940732358705212133793"
      "status" => 1,
      "familyName" => "Correia",
      "givenName" => "Nelson"
    }
  """
  def transform_profile_data_to_person(profile) do
    profile
    |> Map.put("familyName", profile["family_name"])
    |> Map.put("givenName", profile["given_name"])
    |> Map.put("locale", profile["locale"])
    |> Map.put("picture", profile["picture"])
    |> Map.put("status", 1)
  end
end
