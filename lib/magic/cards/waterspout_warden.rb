module Magic
  module Cards
    WaterspoutWarden = Creature("Waterspout Warden") do
      cost generic: 2, blue: 1
      creature_type("Frog Soldier")
      power 3
      toughness 2
    end

    class WaterspoutWarden < Creature
      # Whenever this creature attacks, if another creature entered the battlefield under your control this
      # turn, this creature gains flying until end of turn.
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor } && entered_this_turn?
        end

        def entered_this_turn?
          game.current_turn.events.any? do |entered|
            entered.is_a?(Events::EnteredTheBattlefield) && entered.permanent != actor && entered.permanent.creature? && entered.permanent.controller == controller
          end
        end

        def call
          give_keyword(actor, :flying)
        end
      end

      def event_handlers = super.merge(Events::FinalAttackersDeclared => AttacksTrigger)
    end
  end
end
