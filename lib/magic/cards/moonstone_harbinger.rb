module Magic
  module Cards
    MoonstoneHarbinger = Creature("Moonstone Harbinger") do
      cost generic: 2, black: 1
      creature_type("Bat Warrior")
      keywords :flying, :deathtouch
      power 1
      toughness 3
    end

    class MoonstoneHarbinger < Creature
      # Whenever you gain or lose life during your turn, Bats you control get +1/+0 and gain deathtouch until
      # end of turn. This ability triggers only once each turn.
      class LifeChangeTrigger < TriggeredAbility::OncePerTurn
        def should_perform? = event.player == controller && controllers_turn?

        # OncePerTurn keys on event.permanent; this watches a player event, so it marks the source itself.
        def trigger!
          return false unless should_perform? && !actor.triggered_once_this_turn?(self.class)

          actor.trigger_once_this_turn!(self.class)
          true
        end

        def call
          battlefield.controlled_by(controller).creatures.select { _1.type?("Bat") }.each do |bat|
            pump(bat, 1, 0)
            trigger_effect(:grant_keyword, target: bat, keyword: :deathtouch)
          end
        end
      end

      def event_handlers = super.merge(Events::LifeGain => LifeChangeTrigger, Events::LifeLoss => LifeChangeTrigger)
    end
  end
end
