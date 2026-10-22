module Magic
  module Cards
    EldraziLinebreaker = Creature("Eldrazi Linebreaker") do
      cost generic: 1, colorless: 1, red: 1
      creature_type "Eldrazi"
      power 3
      toughness 3
      keywords :devoid, :trample
    end

    class EldraziLinebreaker < Creature
      # "...target creature you control gains haste and gets +X/+0 until end of turn, where X is the number of
      # Eldrazi you control." X is counted on resolution.
      class PumpChoice < Magic::Choice::Targeted
        def choices = controller.creatures

        def choice_amount = 1

        # Mandatory: declining takes the default of the first legal creature.
        def decline!
          resolve!(target: choices.first)
        end

        def resolve!(target:)
          give_keyword(target, :haste)
          pump(target, controller.creatures.by_type("Eldrazi").count, 0)
        end
      end

      # "At the beginning of combat on your turn, ..."
      class BeginningOfCombatTrigger < TriggeredAbility
        def should_perform? = event.active_player == controller

        def call
          game.add_choice(PumpChoice.new(actor:))
        end
      end

      def event_handlers = { Events::BeginningOfCombat => BeginningOfCombatTrigger }
    end
  end
end
