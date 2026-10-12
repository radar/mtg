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
          game.opponents(controller).each { deal_damage(2, to: _1) }
        end
      end

      def event_handlers = { Events::BeginningOfEndStep => EachEndStepIfCounterPutTrigger }
    end
  end
end
