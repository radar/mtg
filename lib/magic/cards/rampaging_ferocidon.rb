module Magic
  module Cards
    RampagingFerocidon = Creature("Rampaging Ferocidon") do
      cost generic: 2, red: 1
      creature_type "Dinosaur"
      keywords :menace
      power 3
      toughness 3
    end

    class RampagingFerocidon < Creature
      # "Players can't gain life."
      class NoLifeGain < StaticAbility
        def prevents_life_gain?(_player) = true
      end

      # "Whenever another creature enters, this creature deals 1 damage to that creature's controller."
      class CreatureEnteredTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = another_creature?

        def call
          deal_damage 1, to: event.permanent.controller
        end
      end

      def static_abilities = [NoLifeGain]
      def event_handlers = { Events::EnteredTheBattlefield => CreatureEnteredTrigger }
    end
  end
end
