defmodule AppWeb.GoogleAuthControllerTest do
  use AppWeb.ConnCase


	test "transform_profile_data_to_person/1 transforms profile to person", %{conn: conn} do
		
		profile = %{
		  "email" => "nelson@gmail.com",
		  "email_verified" => true,
		  "family_name" => "Correia",
		  "given_name" => "Nelson",
		  "locale" => "en",
		  "name" => "Nelson Correia",
		  "picture" => "https://lh3.googleusercontent.com/a-/AAuE7mApnYb260YC1JY7aPUBxwk8iNzVKB5Q3x_8d3-ThA",
		  "sub" => "940732358705212133793"
		}
		expected = %{
			"email" => "nelson@gmail.com",
			"status" => 1,
			"familyName" => "Correia",
      "givenName" => "Nelson",
		}
		person = AppWeb.GoogleAuthController.transform_profile_data_to_person(profile)
		
		assert Map.equal?(expected, person)
	end

end