module Magic
  module Cards
    MaraudingBlightPriest = Creature("Marauding Blight-Priest") do
      cost generic: 2, black: 1
      creature_type("Vampire Cleric")
      power 3
      toughness 2
    end

    class MaraudingBlightPriest < Creature
      class LifeGainTrigger < TriggeredAbility
        def should_perform?
          you?
        end

        def call
          game.opponents(controller).each { trigger_effect(:lose_life, target: _1, life: 1) }
        end
      end

      def event_handlers = { Events::LifeGain => LifeGainTrigger }
    end
  end
end
