FactoryGirl.define do
  factory :country do
    sequence :name do |n|
      "#{Faker::Address.country}#{n}#{rand}"
    end
    sequence :iso_alpha2 do |n|
      "#{Faker::Lorem.word}#{n}#{rand}"
    end
    sequence :iso_alpha3 do |n|
      "#{Faker::Lorem.word}#{n}#{rand}"
    end
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
