defmodule AppWeb.GoogleAuthControllerTest do
  use App.DataCase

	test "transform_profile_data_to_person/1 transforms profile to person" do

		profile = %{
		  "email" => "nelson@gmail.com",
		  "email_verified" => true,
		  "family_name" => "Correia",
		  "given_name" => "Nelson",
		  "locale" => "en",
		  "name" => "Nelson Correia",
		  "picture" => "https://lh3.googleusercontent.com/a-/AAuE7mApnYb260YC1JY7a",
		  "sub" => "940732358705212133793"
		}
		expected = %{
			"email" => "nelson@gmail.com",
			"email_verified" => true,
			"familyName" => "Correia",
			"family_name" => "Correia",
			"givenName" => "Nelson",
			"given_name" => "Nelson",
			"locale" => "en",
			"name" => "Nelson Correia",
			"picture" => "https://lh3.googleusercontent.com/a-/AAuE7mApnYb260YC1JY7a",
			"status" => 1,
			"sub" => "940732358705212133793"
		}
		# invoke our transformer function using the sample data:
		person = AppWeb.GoogleAuthController.transform_profile_data_to_person(profile)
		
		assert Map.equal?(expected, person)
	end

end