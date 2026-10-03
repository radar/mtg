module Magic
  module Cards
    DictateOfKruphix = Enchantment("Dictate of Kruphix") do
      cost generic: 1, blue: 2
      keywords :flash
    end

    class DictateOfKruphix < Enchantment
      class DrawStepTrigger < TriggeredAbility
        def call
          [that_player].each { trigger_effect(:draw_cards, player: _1) }
        end
      end

      def event_handlers = { Events::DrawStep => DrawStepTrigger }
    end
  end
end
