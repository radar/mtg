module Magic
  module Cards
    class SugarCoat < Aura
      card_name "Sugar Coat"
      cost generic: 2, blue: 1
      keywords :flash

      def can_enchant?(host, aura:)
        host.respond_to?(:type?) && (host.type?("Creature") || host.type?("Food"))
      end

      def target_choices = battlefield.creatures + battlefield.by_any_type("Food")

      # Enchanted permanent is a colorless Food artifact with "{2}, {T}, Sacrifice this artifact: You gain 3
      # life" and loses all other card types and abilities.
      class FoodTransformation < Abilities::Static::CharacteristicSetting
        applies_to_target
        sets_types T::Artifact, "Food"
        sets_colors
        loses_all_abilities
      end

      class FoodAbility < Abilities::Static::GrantActivatedAbilities
        attr_reader :source

        def applies_to?(permanent) = permanent == source.attached_to

        def granted_abilities = [Tokens::Food::GainLife]
      end

      def static_abilities = [FoodTransformation, FoodAbility]
    end
  end
end
