def australia
  postal_address_template = %(%{line1}
%{line2}
%{line3}
%{line4}
%{locality} %{state}  %{postcode}
%{country})

  Country.create!(name: 'Australia', iso_alpha2: 'au', iso_alpha3: 'aus',
                  postal_address_template: postal_address_template)
end

australia
