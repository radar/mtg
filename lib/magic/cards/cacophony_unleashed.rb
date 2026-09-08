module Magic
  module Cards
    CacophonyUnleashed = Enchantment("Cacophony Unleashed") do
      cost generic: 5, black: 2
    end

    class CacophonyUnleashed < Enchantment
      class CastTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          this? && actor.cast?
        end

        def call
          game.battlefield.creatures.reject(&:enchantment?).each do |creature|
            actor.trigger_effect(:destroy_target, target: creature)
          end
        end
      end

      class EnchantmentTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          enchantment? && under_your_control?
        end

        def call
          actor.add_types(T::Super::Legendary, T::Creature, T::Creatures["Nightmare"], T::Creatures["God"])
          actor.modify_base_power(6)
          actor.modify_base_toughness(6)
          actor.grant_keyword(Cards::Keywords::MENACE)
          actor.grant_keyword(Cards::Keywords::DEATHTOUCH)
        end
      end

      def event_handlers
        {
          Events::EnteredTheBattlefield => [CastTrigger, EnchantmentTrigger]
        }
      end
    end
  end
end