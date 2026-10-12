module Magic
  module Cards
    WaxWaneWitness = Creature("Wax-Wane Witness") do
      cost generic: 3, white: 1
      creature_type("Bat Cleric")
      keywords :flying, :vigilance
      power 2
      toughness 4
    end

    class WaxWaneWitness < Creature
      # Whenever you gain or lose life during your turn, this creature gets +1/+0 until end of turn.
      class LifeChangeTrigger < TriggeredAbility
        def should_perform? = event.player == controller && controllers_turn?

        def call
          trigger_effect(:modify_power_toughness, power: 1, toughness: 0, target: actor, until_eot: true)
        end
      end

      def event_handlers = super.merge(Events::LifeGain => LifeChangeTrigger, Events::LifeLoss => LifeChangeTrigger)
    end
  end
end
