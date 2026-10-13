module Magic
  module Cards
    MouseTrapper = Creature("Mouse Trapper") do
      cost generic: 2, white: 1
      creature_type("Mouse Soldier")
      keywords :flash
      power 3
      toughness 2
    end

    class MouseTrapper < Creature
      # Valiant -- tap target creature an opponent controls.
      class ValiantTrigger < TriggeredAbility::Valiant
        class TapChoice < Magic::Choice::Targeted
          def choices = battlefield.creatures.not_controlled_by(controller)

          def choice_amount = 1

          def resolve!(target:)
            tap_permanent(target)
          end
        end

        def call
          game.add_choice(TapChoice.new(actor: actor))
        end
      end

      def event_handlers = super.merge(ValiantTrigger.handlers)
    end
  end
end
