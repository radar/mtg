module Magic
  module Cards
    SuturePriest = Creature("Suture Priest") do
      cost generic: 1, white: 1
      creature_type "Phyrexian Cleric"
      power 1
      toughness 1
    end

    class SuturePriest < Creature
      # Both triggers say "you may", and doing it is never worse, so they always happen. One handler decides which
      # of the two it is: another creature of yours gains you 1 life, a creature an opponent controls costs its
      # controller 1.
      class CreatureEnteredTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          creature? && event.permanent != actor
        end

        def call
          if under_your_control?
            trigger_effect(:gain_life, target: controller, life: 1)
          else
            trigger_effect(:lose_life, target: event.permanent.controller, life: 1)
          end
        end
      end

      def event_handlers
        super.merge(Events::EnteredTheBattlefield => CreatureEnteredTrigger)
      end
    end
  end
end
