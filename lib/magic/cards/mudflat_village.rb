module Magic
  module Cards
    MudflatVillage = Card("Mudflat Village") do
      type T::Land
    end

    class MudflatVillage < Card
      TRIBES = %w[Bat Lizard Rat Squirrel].freeze

      class ColorlessMana < Magic::TapManaAbility
        choices :colorless
      end

      # {T}: Add {B}. Spend this mana only to cast a creature spell.
      class CreatureMana < Magic::TapManaAbility
        choices :black

        def mana_restriction = ManaRestriction::CreatureSpells.new
      end

      # {1}{B}, {T}, Sacrifice this land: Return target Bat, Lizard, Rat, or Squirrel card from your graveyard
      # to your hand.
      class VillageAbility < Magic::ActivatedAbility
        costs "{1}{B}, {T}, Sacrifice {this}"

        def target_choices
          controller.graveyard.select { |card| MudflatVillage::TRIBES.any? { card.type?(_1) } }
        end

        def resolve!(target:)
          target.move_to_hand!
        end
      end

      def activated_abilities = [ColorlessMana, CreatureMana, VillageAbility]
    end
  end
end
