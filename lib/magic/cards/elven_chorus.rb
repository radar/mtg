module Magic
  module Cards
    ElvenChorus = Enchantment("Elven Chorus") do
      cost generic: 3, green: 1
    end

    class ElvenChorus < Enchantment
      # "You may look at the top card of your library any time." (a marker: the engine has no private-look hook) and
      # "You may cast creature spells from the top of your library."
      class TopLibraryPermission < StaticAbility
        def may_look_at_top_card?(player)
          player == controller
        end

        def permits_casting_from_top?(card)
          card.owner == controller && card == controller.library.first && card.creature?
        end
      end

      # "{T}: Add one mana of any color."
      class AnyColorManaAbility < Magic::TapManaAbility
        choices :all
      end

      # "Creatures you control have '{T}: Add one mana of any color.'"
      class GrantManaAbility < Abilities::Static::GrantActivatedAbilities
        def applies_to?(permanent)
          permanent.creature? && permanent.controller == controller
        end

        def granted_abilities = [AnyColorManaAbility]
      end

      def static_abilities = [TopLibraryPermission, GrantManaAbility]
    end
  end
end
