module Magic
  module Cards
    BrambleguardVeteran = Creature("Brambleguard Veteran") do
      cost generic: 1, green: 2
      creature_type("Raccoon Warrior")
      power 3
      toughness 4
    end

    class BrambleguardVeteran < Creature
      # Whenever you expend 4, Raccoons you control get +1/+1 and gain vigilance until end of turn.
      class ExpendTrigger < TriggeredAbility::Expend
        def threshold = 4

        def call
          battlefield.controlled_by(controller).creatures.select { _1.type?("Raccoon") }.each do |raccoon|
            pump(raccoon, 1, 1)
            trigger_effect(:grant_keyword, target: raccoon, keyword: :vigilance)
          end
        end
      end

      def event_handlers = super.merge(ExpendTrigger.handlers)
    end
  end
end
