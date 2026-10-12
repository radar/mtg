module Magic
  module Cards
    FatefulDiscovery = Enchantment("Fateful Discovery") do
      cost generic: 3, blue: 2
    end

    class FatefulDiscovery < Enchantment
      class ArtifactEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          under_your_control? && event.permanent.artifact?
        end

        def call
          draw_card
        end
      end

      def event_handlers = super.merge(Events::EnteredTheBattlefield => ArtifactEntersTrigger)
    end
  end
end
