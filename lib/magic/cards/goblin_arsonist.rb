module Magic
  module Cards
    GoblinArsonist = Creature("Goblin Arsonist") do
      power 1
      toughness 1
      cost red: 1
      creature_type "Goblin Shaman"
    end

    class GoblinArsonist < Creature
      class DamageChoice < Magic::Choice::Targeted
        def choices = game.any_target
        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:deal_damage, damage: 1, target: target)
        end
      end

      class MayDamageChoice < Magic::Choice::May
        def resolve!
          game.choices.add(DamageChoice.new(actor: actor))
        end
      end

      class Death < TriggeredAbility::Death
        def call
          game.choices.add(MayDamageChoice.new(actor: actor))
        end
      end

      def death_triggers = [Death]
    end
  end
end
