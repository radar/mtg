module Magic
  module Cards
    class BeastWithin < Instant
      card_name "Beast Within"
      cost generic: 2, green: 1

      BeastToken = Token.create("Beast") do
        creature_type "Beast"
        power 3
        toughness 3
        colors :green
      end

      def target_choices
        battlefield.permanents
      end

      def resolve!(target:)
        controller = target.controller
        trigger_effect(:destroy_target, target: target)
        trigger_effect(:create_token, controller: controller, token_class: BeastToken)
      end
    end
  end
end