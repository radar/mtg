module Magic
  module Cards
    PitchburnDevils = Creature("Pitchburn Devils") do
      cost generic: 4, red: 1
      creature_type "Devil"
      power 3
      toughness 3
    end

    class PitchburnDevils < Creature
      class DamageChoice < Magic::Choice::Targeted
        def choices = game.any_target
        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:deal_damage, target:, damage: 3)
        end
      end

      # "When this creature dies, it deals 3 damage to any target."
      class DiesTrigger < TriggeredAbility::Death
        def call
          game.add_choice(DamageChoice.new(actor:))
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
