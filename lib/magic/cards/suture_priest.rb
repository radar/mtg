module Magic
  module Cards
    SuturePriest = Creature("Suture Priest") do
      cost generic: 1, white: 1
      creature_type "Phyrexian Cleric"
      power 1
      toughness 1
    end

    class SuturePriest < Creature
      # "Whenever another creature you control enters, you may gain 1 life."
      class GainLifeChoice < Magic::Choice::May
        def resolve!
          trigger_effect(:gain_life, target: controller, life: 1)
        end
      end

      # "Whenever a creature an opponent controls enters, you may have that player lose 1 life."
      class LoseLifeChoice < Magic::Choice::May
        def initialize(actor:, player:)
          @player = player
          super(actor: actor)
        end

        def resolve!
          trigger_effect(:lose_life, target: @player, life: 1)
        end
      end

      # One handler decides which of the two it is, from who controls the creature that entered.
      class CreatureEnteredTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          creature? && event.permanent != actor
        end

        def call
          if under_your_control?
            game.add_choice(GainLifeChoice.new(actor: actor))
          else
            game.add_choice(LoseLifeChoice.new(actor: actor, player: event.permanent.controller))
          end
        end
      end

      def event_handlers
        super.merge(Events::EnteredTheBattlefield => CreatureEnteredTrigger)
      end
    end
  end
end
