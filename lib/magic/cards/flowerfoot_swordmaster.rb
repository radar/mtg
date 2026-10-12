module Magic
  module Cards
    FlowerfootSwordmaster = Creature("Flowerfoot Swordmaster") do
      cost white: 1
      creature_type("Mouse Soldier")
      power 1
      toughness 2
      offspring generic: 2
    end

    class FlowerfootSwordmaster < Creature
      # Valiant -- Mice you control get +1/+0 until end of turn.
      class ValiantTrigger < TriggeredAbility::Valiant
        def call
          battlefield.controlled_by(controller).creatures.select { _1.type?("Mouse") }.each do |mouse|
            pump(mouse, 1, 0)
          end
        end
      end

      def event_handlers = super.merge(ValiantTrigger.handlers)
    end
  end
end
