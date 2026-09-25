module Magic
  class ReplacementEffect
    # "If an effect would put one or more counters on a permanent you control, it puts twice that
    # many of those counters on that permanent instead." (Doubling Season)
    class CountersOnYourPermanentsDoubler < CounterAmountChange
      def self.matchers = [Effects::AddCounterToPermanent]

      def applies?(effect) = effect.target.controller == receiver.controller

      private

      def new_amount(amount) = amount * 2
    end
  end
end
