module Magic
  module Cards
    RoughshodDuo = Creature("Roughshod Duo") do
      cost generic: 2, red: 1
      creature_type("Mouse Raccoon")
      keywords :trample
      power 3
      toughness 2
    end

    class RoughshodDuo < Creature
      # Whenever you expend 4, target creature you control gets +1/+1 and gains trample until end of turn.
      class ExpendTrigger < TriggeredAbility::Expend
        class PumpChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            pump(target, 1, 1)
            trigger_effect(:grant_keyword, target: target, keyword: :trample)
          end
        end

        def threshold = 4

        def call
          game.add_choice(PumpChoice.new(actor: actor))
        end
      end

      def event_handlers = super.merge(ExpendTrigger.handlers)
    end
  end
end
