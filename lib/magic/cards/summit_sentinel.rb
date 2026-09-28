module Magic
  module Cards
    SummitSentinel = Creature("Summit Sentinel") do
      cost generic: 1, blue: 1
      creature_type("Elemental Soldier")
      power 1
      toughness 3
    end

    class SummitSentinel < Creature
      class DiesTrigger < TriggeredAbility::Death
        def call
          trigger_effect(:draw_card)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
