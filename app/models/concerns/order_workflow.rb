module OrderWorkflow
  extend ActiveSupport::Concern

  def can_omit_customer_details?
    new? || details? || cancelled? || abandoned?
  end

  included do
    include Workflow

    workflow do
      # New order has been built, and is being saved.
      state :new do
        event :submit, transitions_to: :details
      end

      state :details do
        event :store_details, transitions_to: :shipping
        event :cancel, transitions_to: :cancelled
        event :abandon, transitions_to: :abandoned
      end

      state :shipping do
        event :store_shipping, transitions_to: :pending
        event :cancel, transitions_to: :cancelled
        event :abandon, transitions_to: :abandoned
      end

      # Order total has been calculated. Now showing details and total price to
      # customer for confirmation.
      state :pending do
        event :finalize, transitions_to: :finalized
        event :cancel, transitions_to: :cancelled
        event :abandon, transitions_to: :abandoned
      end

      # Confirmed by customer, order finalised and ready for payment.
      state :finalized do
        event :accept, transitions_to: :accepted
        event :hold, transitions_to: :on_hold
        event :cancel, transitions_to: :cancelled
        event :abandon, transitions_to: :abandoned
      end

      # Order was cancelled by the customer.
      state :cancelled

      # Order timed out and was automatically cancelled.
      state :abandoned

      # Order was accepted by the store and is being processed internally.
      state :accepted do
        event :hold, transitions_to: :on_hold
        event :ship, transitions_to: :shipped
      end

      # Order was placed on hold by the store owner, pending further action.
      state :on_hold do
        event :accept, transitions_to: :accepted
        event :reject, transitions_to: :rejected
      end

      # Order was shipped to customer.
      state :shipped do
        event :adjust, transitions_to: :adjusted
        event :refund, transitions_to: :refunded
      end

      # Order has been altered by the store owner after shipping.
      state :adjusted do
        event :refund, transitions_to: :refunded
      end

      # Order was rejected by the store owner. Reserved stock has been released
      # back to inventory.
      state :rejected do
        event :refund, transitions_to: :refunded
        event :hold, transitions_to: :on_hold
      end

      # Order has been completely refunded.
      state :refunded
    end
  end
end
