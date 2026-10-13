module Magic
  module Cards
    class SuspendedSentence < Instant
      card_name "Suspended Sentence"
      cost generic: 3, black: 1
      suspend 3, generic: 1, black: 1

      def single_target? = true

      def target_choices = battlefield.not_controlled_by(controller).creatures

      # "Destroy target creature an opponent controls. That player loses 3 life. Exile Suspended Sentence with three time
      # counters on it."
      def resolve!(target:)
        opponent = target.controller
        destroy(target)
        trigger_effect(:lose_life, target: opponent, life: 3)
        self.exile_with_time_counters = 3
      end
    end
  end
end
