module Magic
  module Cards
    ShortSword = Equipment("Short Sword") do
      cost generic: 1

      equip [Costs::Mana.new(generic: 1)]
    end

    class ShortSword < Equipment
      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applies_to_target

      end

      def static_abilities
        [PowerAndToughnessModification]
      end
    end
  end
end
