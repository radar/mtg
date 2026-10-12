module Magic
  module Cards
    StarfieldOfNyx = Enchantment("Starfield of Nyx") do
      cost generic: 4, white: 1
    end

    class StarfieldOfNyx < Enchantment
      # At the beginning of your upkeep, you may return target enchantment card from your graveyard to the battlefield.
      # (An Aura would need something to enchant, so only non-Aura enchantment cards are offered.)
      class UpkeepChoice < Magic::Choice::May
        def prompt = "Return an enchantment card from your graveyard to the battlefield?"

        def choices
          controller.graveyard.cards.enchantments.reject { |card| card.is_a?(Aura) }
        end

        def resolve!(target:)
          target.resolve!
        end
      end

      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          choice = UpkeepChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # As long as you control five or more enchantments, each other non-Aura enchantment you control is a creature in
      # addition to its other types and has base power and base toughness each equal to its mana value.
      module EnchantmentCreatures
        def applicable_targets
          return [] if source.controller.permanents.enchantments.count < 5

          source.controller.permanents.enchantments.reject { |permanent| permanent.card.is_a?(Aura) || permanent == source }
        end
      end

      class EnchantmentCreatureTypes < Abilities::Static::TypeGrant
        include EnchantmentCreatures

        def type_grants
          [T::Creature]
        end
      end

      class EnchantmentBasePowerAndToughness < Abilities::Static::CharacteristicSetting
        include EnchantmentCreatures

        def set_base_power(permanent) = permanent.mana_value
        def set_base_toughness(permanent) = permanent.mana_value
      end

      def static_abilities = [EnchantmentCreatureTypes, EnchantmentBasePowerAndToughness]

      def event_handlers
        { Events::BeginningOfUpkeep => UpkeepTrigger }
      end
    end
  end
end
