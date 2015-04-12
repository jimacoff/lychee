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
%{locality}  %{postcode}
%{country})
    end

    trait :with_states do
      postal_address_template do
        %(%{line1}
%{line2}
%{line3}
%{line4}
%{locality} %{state}  %{postcode}
%{country})
      end

      after(:create) do |c|
        create_list(:state, 5, country: c)
      end
    end
  end
end
