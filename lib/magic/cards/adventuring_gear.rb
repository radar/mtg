module Magic
  module Cards
    AdventuringGear = Equipment("Adventuring Gear") do
      cost generic: 1
      equip [Costs::Mana.new(generic: 1)]
    end

    class AdventuringGear < Equipment
      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          you?
        end

        def call
          pump(actor.attached_to, 2, 2)
        end
      end

      def event_handlers = { Events::Landfall => LandfallTrigger }
    end
  end
end
