FactoryGirl.define do
  factory :variant do
    product
    after(:create) do |variant|
      variation = create(:variation, product: variant.product)
      variation.variation_instances << create(:variation_instance,
                                              variation: variation,
                                              variant: variant)
    end
  end
end
