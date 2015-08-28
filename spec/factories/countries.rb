FactoryGirl.define do
  factory :country do
    sequence :name do |n|
      "#{Faker::Address.country}#{n}"
    end
    sequence :iso_alpha2 do |a2|
      "#{Faker::Lorem.word}#{a2}"
    end
    sequence :iso_alpha3 do |a3|
      "#{Faker::Lorem.word}#{a3}"
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
