class SpecificationValidator < ActiveModel::Validator
  SPECIFICATION_SCHEMA = File.read(Rails.root.join(
                        *%w(config schemas json specifications.json)))

  def validate(record)
    return unless record.specifications

    errors = JSON::Validator.fully_validate(SPECIFICATION_SCHEMA,
                                            record.specifications)
    record.errors[:specifications].push(errors).flatten! if errors
  end
end
