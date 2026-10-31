module Magic
  module Cards
    GrmaWormtongue = Creature("Gríma Wormtongue") do
      cost generic: 2, black: 1
      legendary_creature_type "Human Advisor"
      power 1
      toughness 4
    end

    class GrmaWormtongue < Creature
      # "Your opponents can't gain life."
      class OpponentsCantGainLife < StaticAbility
        def prevents_life_gain?(player) = player != controller
      end

      # "{T}, Sacrifice another creature: Target player loses 1 life. If the sacrificed creature was legendary, amass
      # Orcs 2."
      class DrainAbility < Magic::ActivatedAbility
        costs "{T}, Sacrifice another creature"

        def target_choices = game.players

        def single_target? = true

        def resolve!(target:, sacrificed:)
          lose_life(target, 1)
          return unless sacrificed.first.legendary?

          Magic::Amass.call(source: source, controller: controller, amount: 2, subtype: "Orc")
        end
      end

      def static_abilities = [OpponentsCantGainLife]
      def activated_abilities = [DrainAbility]
    end
  end
end
