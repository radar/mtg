module Magic
  module Cards
    class PyrrhicStrike < Instant
      card_name "Pyrrhic Strike"
      cost generic: 2, white: 1

      # As an additional cost to cast this spell, you may blight 2.
      def kicker_cost
        @blight_kicker_cost ||= Costs::BlightKicker.new(amount: 2)
      end

      # Choose one. If this spell's additional cost was paid, choose both instead. The number of
      # modes is fixed as the spell is cast, so pay the additional cost before choosing modes.
      def modes_to_choose = kicker_cost.paid? ? 2 : 1

      # Destroy target artifact or enchantment.
      class DestroyArtifactOrEnchantment < Mode
        def target_choices = battlefield.permanents.by_any_type(T::Artifact, T::Enchantment)

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
          card.kicker_cost.reset!
        end
      end

      # Destroy target creature with mana value 3 or greater.
      class DestroyCreature < Mode
        def target_choices = battlefield.creatures.select { _1.cmc >= 3 }

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
          card.kicker_cost.reset!
        end
      end

      modes DestroyArtifactOrEnchantment, DestroyCreature
    end
  end
end
