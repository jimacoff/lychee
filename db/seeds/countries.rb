# rubocop:disable Metrics/MethodLength
def australia
  postal_address_template = %(%{line1}
%{line2}
%{line3}
%{line4}
%{locality} %{state}  %{postcode}
%{country})

  au = Country.create!(name: 'Australia', iso_alpha2: 'au', iso_alpha3: 'aus',
                       postal_address_template: postal_address_template)

  State.create!(name: 'New South Wales', iso_code: 'AU-NSW',
                postal_format: 'NSW', country: au)
  State.create!(name: 'Queensland', iso_code: 'AU-QLD',
                postal_format: 'QLD', country: au)
  State.create!(name: 'South Australia', iso_code: 'AU-SA',
                postal_format: 'SA', country: au)
  State.create!(name: 'Tasmania', iso_code: 'AU-TAS',
                postal_format: 'TAS', country: au)
  State.create!(name: 'Victoria', iso_code: 'AU-VIC',
                postal_format: 'VIC', country: au)
  State.create!(name: 'Western Australia', iso_code: 'AU-WA',
                postal_format: 'WA', country: au)
  State.create!(name: 'Australian Capital Territory', iso_code: 'AU-ACT',
                postal_format: 'ACT', country: au)
  State.create!(name: 'Northern Territory', iso_code: 'AU-NT',
                postal_format: 'NT', country: au)
end
# rubocop:enable Metrics/MethodLength

australia
