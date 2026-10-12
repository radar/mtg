module Magic
  module Cards
    ThievingOtter = Creature("Thieving Otter") do
      cost generic: 2, blue: 1
      creature_type("Otter")
      power 2
      toughness 2
    end

    class ThievingOtter < Creature
      # Whenever this creature deals damage to an opponent, draw a card.
      class DamageTrigger < TriggeredAbility
        def should_perform? = event.source == actor && opponents.include?(event.target)

        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def event_handlers = super.merge(Events::DamageDealt => DamageTrigger)
    end
  end
end
