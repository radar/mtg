module Magic
  module Cards
    PrimeSpeakerZegana = Creature("Prime Speaker Zegana") do
      cost generic: 2, green: 2, blue: 2
      legendary_creature_type("Merfolk Wizard")
      power 1
      toughness 1
    end

    class PrimeSpeakerZegana < Creature
      def entering_counters
        controller = self.controller || owner
        { "+1/+1" => (controller.creatures.except(self).map(&:power).max || 0) }
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:draw_cards, number_to_draw: actor.power)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
