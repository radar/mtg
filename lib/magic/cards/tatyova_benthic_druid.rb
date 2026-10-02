module Magic
  module Cards
    TatyovaBenthicDruid = Creature("Tatyova, Benthic Druid") do
      cost generic: 3, green: 1, blue: 1
      legendary_creature_type("Merfolk Druid")
      power 3
      toughness 3
    end

    class TatyovaBenthicDruid < Creature
      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          you?
        end

        def call
          trigger_effect(:gain_life, target: controller, life: 1)
          trigger_effect(:draw_card)
        end
      end

      def event_handlers = { Events::Landfall => LandfallTrigger }
    end
  end
end
