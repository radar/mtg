module Magic
  module Cards
    DranasEmissary = Creature("Drana's Emissary") do
      creature_type("Vampire Cleric Ally")
      cost generic: 1, white: 1, black: 1
      keywords :flying
      power 2
      toughness 2
    end

    class DranasEmissary < Creature
      class BeginningOfUpkeepTrigger < TriggeredAbility
        def should_perform?
          controllers_turn?
        end

        def call
          controller.gain_life(1)

          opponents.each do |opponent|
            actor.trigger_effect(
              :deal_damage,
              damage: 1,
              target: opponent,
            )
          end
        end
      end

      def event_handlers
        {
          Events::BeginningOfUpkeep => BeginningOfUpkeepTrigger
        }
      end
    end
  end
end
