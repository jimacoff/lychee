FactoryGirl.define do
  factory :country do
    name { SecureRandom.hex }
    iso_alpha2 { SecureRandom.hex }
    iso_alpha3 { SecureRandom.hex }

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
