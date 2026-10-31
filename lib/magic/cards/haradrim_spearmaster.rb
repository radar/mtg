module Magic
  module Cards
    HaradrimSpearmaster = Creature("Haradrim Spearmaster") do
      cost generic: 2, red: 1
      creature_type "Human Warrior"
      keywords :reach
      power 2
      toughness 3
    end

    class HaradrimSpearmaster < Creature
      # "Another target creature you control gets +1/+0 until end of turn." The target is mandatory (CR 603.3d), so
      # declining picks the first legal creature.
      class PumpChoice < Magic::Choice::Targeted
        def choices = actor.controller.creatures.reject { _1 == actor }
        def choice_amount = 1

        def resolve!(target:)
          pump(target, 1, 0)
        end

        def decline! = resolve!(target: choices.first)
      end

      # "At the beginning of combat on your turn, ..."
      class BeginningOfCombatTrigger < TriggeredAbility
        def should_perform? = event.active_player == controller

        def call
          choice = PumpChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::BeginningOfCombat => BeginningOfCombatTrigger }
    end
  end
end
