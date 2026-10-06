module Magic
  module Cards
    DemonicEmbrace = Aura("Demonic Embrace") do
      cost generic: 1, black: 2
    end

    class DemonicEmbrace < Aura
      enchant "Creature"

      def target_choices = battlefield.creatures

      # "Enchanted creature gets +3/+1, has flying, and is a Demon in addition to its other types."
      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 3, toughness: 1
        applies_to_target
      end

      class FlyingGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FLYING
        applies_to_target
      end

      class DemonType < Abilities::Static::TypeGrant
        type_grants T::Creatures["Demon"]
        applies_to_target
      end

      def static_abilities = [PowerAndToughnessModification, FlyingGrant, DemonType]

      # "You may cast this card from your graveyard by paying 3 life and discarding a card in addition to paying its
      # other costs." Pay them with `pay_additional_life` and `pay_discard(card)`.
      def may_cast_from_graveyard? = zone&.graveyard? || false

      def additional_costs
        return [] unless zone&.graveyard?

        [Costs::PayLife.new(self, amount: 3), Costs::Discard.new(owner)]
      end
    end
  end
end
