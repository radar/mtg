module Magic
  module Cards
    OinTheBrave = Creature("Óin the Brave") do
      cost generic: 1, red: 1
      legendary_creature_type "Dwarf Warrior"
      power 1
      toughness 3
    end

    class OinTheBrave < Creature
      # "Storied (...)  As long as you have an enduring story, Óin gets +1/+0 and has haste."
      class StoriedPower < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 0
        applicable_targets { [source] }
        conditions { Magic::Storied.enduring_story?(controller) }
      end

      class StoriedHaste < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HASTE
        applicable_targets { [source] }
        conditions { Magic::Storied.enduring_story?(controller) }
      end

      def static_abilities = [StoriedPower, StoriedHaste]

      class LootAbility < Magic::ActivatedAbility
        costs "{1}, {T}, Discard a card"

        def resolve!
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def activated_abilities = [LootAbility]
    end
  end
end
