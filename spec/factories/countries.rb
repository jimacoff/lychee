FactoryGirl.define do
  factory :country do
    name { Faker::Address.country }
    iso_alpha2 { Faker::Lorem.word }
    iso_alpha3 { Faker::Lorem.word }
    postal_address_template do
      %(%{line1}
%{line2}
%{line3}
%{line4}
%{locality} %{state}  %{postcode}
%{country})
    end
  end
end
