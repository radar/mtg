module Magic
  module Cards
    HavocJester = Creature("Havoc Jester") do
      cost generic: 4, red: 1
      creature_type "Devil"
      power 5
      toughness 5
    end

    class HavocJester < Creature
      class DamageChoice < Magic::Choice::Targeted
        def choices = game.any_target
        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:deal_damage, target:, damage: 1)
        end
      end

      # "Whenever you sacrifice a permanent, this creature deals 1 damage to any target."
      class SacrificeTrigger < TriggeredAbility
        def should_perform? = event.permanent.controller == controller

        def call
          game.add_choice(DamageChoice.new(actor:))
        end
      end

      def event_handlers = { Events::PermanentSacrificed => SacrificeTrigger }
    end
  end
end
