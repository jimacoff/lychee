class VariationsValidator < ActiveModel::Validator
  VARIATIONS_SCHEMA = File.read(Rails.root.join(
                        *%w(config schemas json variations.json)))

  def validate(record)
    return unless record.variations

    errors = JSON::Validator.fully_validate(VARIATIONS_SCHEMA,
                                            record.variations)
    record.errors[:variations].push(errors).flatten! if errors
  end
end
