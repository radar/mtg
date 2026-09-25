module Magic
  class ReplacementEffect
    # "If an opponent would put one or more counters on a permanent or player, they put half that
    # many of each of those kinds of counters on that permanent or player instead, rounded down."
    class CountersOpponentPutHalver < CounterAmountChange
      def applies?(effect)
        putter = putter(effect)
        !putter.nil? && putter != receiver.controller
      end

      private

      def new_amount(amount) = amount / 2
    end
  end
end
