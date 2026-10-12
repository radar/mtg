module Magic
  module Cards
    CorpseberryCultivator = Creature("Corpseberry Cultivator") do
      cost "{1}{B/G}{B/G}"
      creature_type("Squirrel Warlock")
      power 2
      toughness 3
    end

    class CorpseberryCultivator < Creature
      # At the beginning of combat on your turn, you may forage.
      class CombatTrigger < TriggeredAbility
        class ForageChoice < Magic::Choice::Forage
        end

        class MayChoice < Magic::Choice::May
          def resolve!
            choice = ForageChoice.new(actor: actor)
            game.choices.add(choice) if choice.possible?
          end
        end

        def should_perform? = controllers_turn?

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      # Whenever you forage, put a +1/+1 counter on this creature.
      class ForageTrigger < TriggeredAbility
        def should_perform? = event.player == controller

        def call
          add_counter("+1/+1")
        end
      end

      def event_handlers = super.merge(Events::BeginningOfCombat => CombatTrigger, Events::Forage => ForageTrigger)
    end
  end
end
