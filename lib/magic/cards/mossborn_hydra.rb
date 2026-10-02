module Magic
  module Cards
    MossbornHydra = Creature("Mossborn Hydra") do
      cost generic: 2, green: 1
      creature_type("Elemental Hydra")
      keywords :trample
      power 0
      toughness 0
    end

    class MossbornHydra < Creature
      enters_with_counters "+1/+1", 1

      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          you?
        end

        def call
          trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: actor.counters.of_type(Counters["+1/+1"]).count)
        end
      end

      def event_handlers = { Events::Landfall => LandfallTrigger }
    end
  end
end
