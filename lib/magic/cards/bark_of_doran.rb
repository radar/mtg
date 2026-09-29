module Magic
  module Cards
    class BarkOfDoran < Equipment
      card_name "Bark of Doran"
      cost generic: 1, white: 1
      equip [Costs::Mana.new(generic: 1)]

      # "Equipped creature gets +0/+1."
      class Toughness < Abilities::Static::PowerAndToughnessModification
        modify power: 0, toughness: 1
        applies_to_target
      end

      def static_abilities = [Toughness]

      # "As long as equipped creature's toughness is greater than its power, it assigns combat damage
      # equal to its toughness rather than its power."
      def assigns_toughness_damage?(creature) = creature.toughness > creature.power
    end
  end
end
