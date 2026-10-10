module Magic
  module Cards
    RipchainRazorkin = Creature("Ripchain Razorkin") do
      cost generic: 3, red: 1
      creature_type "Human Berserker"
      power 5
      toughness 3
      keywords :reach
    end

    class RipchainRazorkin < Creature
      # "{2}{R}, Sacrifice a land: Draw a card."
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}{R}, Sacrifice a land"

        def resolve!
          trigger_effect(:draw_card)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
