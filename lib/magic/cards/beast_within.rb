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
        destroy(target)
        create_token(token: BeastToken, controller: controller)
      end
    end
  end
end