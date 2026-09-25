module Magic
  class ReplacementEffect
    # "If you would put one or more counters on a permanent or player, put twice that many of
    # each of those kinds of counters on that permanent or player instead."
    class CountersYouPutDoubler < CounterAmountChange
      def applies?(effect) = putter(effect) == receiver.controller

      private

      def new_amount(amount) = amount * 2
    end
  end
end
