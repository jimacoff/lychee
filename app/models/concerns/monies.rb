module Monies
  module ClassMethods
    def monies(monies)
      monies.each do |money|
        field, calculated, allow_nil = parse_options(money)

        monetize "#{field}_cents", with_model_currency: :currency,
                                   allow_nil: allow_nil

        define_public_methods(field, calculated)

        private

        define_private_methods(field, calculated)
      end
    end

    private

    def parse_options(money)
      calculated = money[:calculated] ? money[:calculated] : false
      allow_nil = money[:allow_nil] ? money[:allow_nil] : false

      [money[:field], calculated, allow_nil]
    end

    def define_public_methods(field, calculated)
      define_setter(field, calculated)
      define_cents_setter(field)
    end

    def define_cents_setter(field)
      define_method("#{field}_cents=") do |_value|
        fail "#{field}_cents cannot be directly set, use ##{field}="
      end
    end

    def define_setter(field, calculated)
      if calculated
        define_method("#{field}=") do |_value|
          fail "#{field} is calculated and cannot be directly set"
        end
      else
        define_method("#{field}=") do |value|
          send("change_#{field}", value)
        end
      end
    end

    def define_private_methods(field, _calculated)
      define_change(field)
    end

    def define_change(field)
      define_method("change_#{field}") do |value|
        money = create_monentary_value(value)
        write_attribute("#{field}_cents", money.cents)
      end
    end
  end

  extend ActiveSupport::Concern

  def self.included(base)
    base.extend(ClassMethods)
  end

  private

  def create_monentary_value(value)
    fail 'Must be Numeric' unless value.is_a? Numeric

    return Money.new(value, currency) if value.is_a?(Integer)
    value.to_money(currency)
  end
end
