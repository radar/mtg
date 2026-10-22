module Magic
  module Cards
    # The land back face of Razorgrass Ambush. It has no mana cost.
    RazorgrassField = Card("Razorgrass Field") do
      type "Land"
    end

    class RazorgrassField < Card
      # "As this land enters, you may pay 3 life. If you don't, it enters tapped."
      def shock_life = 3

      class ManaAbility < Magic::TapManaAbility
        choices :white
      end

      def activated_abilities = [ManaAbility]
    end

    RazorgrassAmbush = Instant("Razorgrass Ambush") do
      cost generic: 1, white: 1
      back_face RazorgrassField
    end

    class RazorgrassAmbush < Instant
      def target_choices
        battlefield.creatures.select do |creature|
          game.current_turn.attacking?(creature) || game.current_turn.blocking?(creature)
        end
      end

      # "Razorgrass Ambush deals 3 damage to target attacking or blocking creature."
      def resolve!(target:)
        deal_damage 3, to: target
      end
    end
  end
end
