module Magic
  module Cards
    PopularEgotist = Creature("Popular Egotist") do
      cost generic: 2, black: 1
      creature_type "Human Rogue"
      power 3
      toughness 2
    end

    class PopularEgotist < Creature
      # "{1}{B}, Sacrifice another creature or enchantment: This creature gains indestructible until end of turn.
      # Tap it."
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}{B}, Sacrifice another creature or enchantment"

        def resolve!
          source.grant_indestructible!
          source.tap!
        end
      end

      # "Whenever you sacrifice a permanent, target opponent loses 1 life and you gain 1 life."
      class SacrificeTrigger < TriggeredAbility
        def should_perform? = event.permanent.controller == controller

        def call
          opponents.each { |opponent| lose_life(opponent, 1) }
          gain_life(1)
        end
      end

      def activated_abilities = [ActivatedAbility]

      def event_handlers
        super.merge({ Events::PermanentSacrificed => SacrificeTrigger }) { |_, old, new| [*old, *new] }
      end
    end
  end
end
