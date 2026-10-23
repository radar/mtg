module Magic
  module Cards
    class ThrabenCharm < Instant
      card_name "Thraben Charm"
      cost generic: 1, white: 1

      # Deals damage equal to twice the number of creatures you control to target creature.
      class DamageCreature < Mode
        def target_choices = battlefield.creatures

        def resolve!(target:)
          deal_damage(controller.creatures.count * 2, to: target)
        end
      end

      # Destroy target enchantment.
      class DestroyEnchantment < Mode
        def target_choices = battlefield.permanents.by_any_type(T::Enchantment)

        def resolve!(target:)
          destroy(target)
        end
      end

      # Exile any number of target players' graveyards. Modelled as one target player per cast.
      class ExileGraveyard < Mode
        def target_choices = game.players

        def resolve!(target:)
          target.graveyard.cards.to_a.each(&:exile!)
        end
      end

      modes DamageCreature, DestroyEnchantment, ExileGraveyard
      choose_modes 1
    end
  end
end
