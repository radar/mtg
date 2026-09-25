module Magic
  module Cards
    LastingTarfire = Enchantment("Lasting Tarfire") do
      cost generic: 1, red: 1
    end

    class LastingTarfire < Enchantment
      class EachEndStepIfCounterPutTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          game.current_turn.events.any? { |e| e.is_a?(Events::CounterAddedToPermanent) && e.permanent.creature? && e.source&.controller == controller }
        end

        def call
          game.opponents(controller).each { trigger_effect(:deal_damage, target: _1, damage: 2) }
        end
      end

      def event_handlers = { Events::BeginningOfEndStep => EachEndStepIfCounterPutTrigger }
    end
  end
end
