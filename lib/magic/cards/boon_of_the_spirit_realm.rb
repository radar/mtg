module Magic
  module Cards
    BoonOfTheSpiritRealm = Enchantment("Boon of the Spirit Realm") do
      cost generic: 3, white: 2
    end

    class BoonOfTheSpiritRealm < Enchantment
      class ConstellationTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          enchantment? && under_your_control?
        end

        def call
          actor.add_counter("blessing")
        end
      end

      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        def power_modification
          source.counters.of_type(Counters::Blessing).count
        end

        alias_method :toughness_modification, :power_modification

        def applicable_targets
          source.controller.creatures
        end
      end

      def event_handlers
        { Events::EnteredTheBattlefield => ConstellationTrigger }
      end

      def static_abilities = [PowerAndToughnessModification]
    end
  end
end