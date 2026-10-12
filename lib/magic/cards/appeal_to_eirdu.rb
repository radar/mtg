module Magic
  module Cards
    class AppealToEirdu < Instant
      card_name "Appeal to Eirdu"
      cost generic: 3, white: 1
      convoke

      def target_choices = battlefield.creatures

      # "One or two target creatures each get +2/+1 until end of turn."
      def resolve!(targets: [])
        targets.first(2).each do |target|
          pump(target, 2, 1)
        end
      end
    end
  end
end
