module Magic
  module Cards
    ChampionsOfThePerfect = Creature("Champions of the Perfect") do
      cost generic: 3, green: 1
      creature_type("Elf Warrior")
      power 6
      toughness 6
    end

    class ChampionsOfThePerfect < Creature
      # As an additional cost to cast this spell, behold an Elf and exile it.
      def additional_costs
        [Costs::Behold.new(self, type: "Elf", exile: true)]
      end

      # Whenever you cast a creature spell, draw a card.
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          spell.creature? && you?
        end

        def call
          trigger_effect(:draw_cards)
        end
      end

      def event_handlers = { Events::SpellCast => SpellCastTrigger }

      # When this creature leaves the battlefield, return the exiled card to its owner's hand.
      def ltb_triggers = [Behold::ReturnExiledCardTrigger]
    end
  end
end
