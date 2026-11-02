module Magic
  module Cards
    MirkwoodBats = Creature("Mirkwood Bats") do
      cost generic: 3, black: 1
      creature_type "Bat"
      power 2
      toughness 3
      keywords :flying
    end

    class MirkwoodBats < Creature
      # "Whenever you create or sacrifice a token, each opponent loses 1 life."
      class CreatedTokenTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent.token? && under_your_control?
        end

        def call
          game.opponents(controller).each { |opponent| lose_life(opponent, 1) }
        end
      end

      class SacrificedTokenTrigger < TriggeredAbility
        def should_perform?
          event.permanent.token? && event.permanent.controller == controller
        end

        def call
          game.opponents(controller).each { |opponent| lose_life(opponent, 1) }
        end
      end

      def event_handlers
        {
          Events::EnteredTheBattlefield => CreatedTokenTrigger,
          Events::PermanentSacrificed => SacrificedTokenTrigger
        }
      end
    end
  end
end
