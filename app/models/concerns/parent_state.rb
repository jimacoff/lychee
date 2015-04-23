module ParentState
  extend ActiveSupport::Concern

  included do
    belongs_to :state

    validate :valid_state
  end

  def valid_state
    return if (country.try(:states?) && state.present?) ||
              (!country.try(:states?) && !state.present?)

    define_invalid_state_errors
  end

  def define_invalid_state_errors
    if country.try(:states?) && !state.present?
      errors.add(:base, 'requires specification of state')
    else
      errors.add(:base, 'does not require specification of state')
    end
  end

  def state=(state)
    if state.nil? || country == state.country
      super(state)
      return
    end

    fail 'State is not associated with Country specified for this object'
  end
end
