module Magic
  module Cards
    GetOut = Instant("Get Out") do
      cost blue: 2
    end

    class GetOut < Instant
      # Counter target creature or enchantment spell.
      class CounterCreatureOrEnchantment < Mode
        def target_choices
          game.stack.spells.select { |spell| spell.card.creature? || spell.card.enchantment? }
        end

        def resolve!(target:)
          trigger_effect(:counter_spell, target: target)
        end
      end

      # Return one or two target creatures and/or enchantments you own to your hand.
      class ReturnToHand < Mode
        def target_choices
          battlefield.select { |permanent| (permanent.creature? || permanent.enchantment?) && permanent.owner == controller }
        end

        def resolve!(targets:)
          targets.first(2).each { |target| trigger_effect(:return_to_owners_hand, target: target) }
        end
      end

      modes CounterCreatureOrEnchantment, ReturnToHand
      choose_modes 1
    end
  end
end
