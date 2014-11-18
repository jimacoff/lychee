class TraitValidator < ActiveModel::Validator
  def validate(record)
    unless record.traits
      record.errors[:traits] << 'Variants must specify at least one trait ' \
                                'that they represent'
      return
    end
    record.traits.reject { |id, _v| Trait.exists?(id) }.each do |id, v|
      record.errors[:traits] << "The trait ID #{id} with value #{v} " \
                                'exhibited by this variant, no longer exists'
    end
  end
end
