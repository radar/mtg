module Magic
  module Cards
    ImpactTremors = Enchantment("Impact Tremors") do
      cost generic: 1, red: 1
    end

    class ImpactTremors < Enchantment
      class EntersTrigger < TriggeredAbility
        def should_perform?
          event.permanent.controller == controller && event.permanent.creature?
        end

        def call
          opponents.each { |opponent| actor.deal_damage(1, to: opponent) }
        end
      end

      def event_handlers
        { Events::EnteredTheBattlefield => EntersTrigger }
      end
    end
  end
end
