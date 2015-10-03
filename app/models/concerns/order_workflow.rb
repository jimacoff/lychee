module OrderWorkflow
  extend ActiveSupport::Concern

  included do
    include Workflow

    workflow do
      # New order has been built, and is being saved.
      state :new do
        event :submit, transitions_to: :collecting
      end

      # Order has been saved and inventory reserved. Now progressing through UI
      # to collect customer details and address, and select a shipping option.
      state :collecting do
        event :calculate, transitions_to: :pending
        event :cancel, transitions_to: :cancelled
        event :abandon, transitions_to: :abandoned
      end

      # Order total has been calculated. Now showing details and total price to
      # customer for confirmation.
      state :pending do
        event :confirm, transitions_to: :confirmed
        event :cancel, transitions_to: :cancelled
        event :abandon, transitions_to: :abandoned
      end

      # Confirmed by customer, order finalised and ready for payment.
      state :confirmed do
        event :pay, transitions_to: :paid
        event :cancel, transitions_to: :cancelled
        event :abandon, transitions_to: :abandoned
      end

      # Order was cancelled by the customer.
      state :cancelled

      # Order timed out and was automatically cancelled.
      state :abandoned

      # Customer has completed payment. Order is submitted to the store and
      # awaiting processing.
      state :paid do
        event :accept, transitions_to: :accepted
        event :hold, transitions_to: :on_hold
      end

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
