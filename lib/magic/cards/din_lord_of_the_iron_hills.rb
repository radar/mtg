module Magic
  module Cards
    DinLordOfTheIronHills = Creature("Dáin, Lord of the Iron Hills") do
      cost generic: 1, white: 1
      legendary_creature_type("Dwarf Noble")
      keywords :vigilance
      power 2
      toughness 2
    end

    class DinLordOfTheIronHills < Creature
      # "Storied ... As long as you have an enduring story, creatures can't attack you unless their controller pays
      # {1} for each of those creatures." (see Actions::DeclareAttacker#attack_tax)
      class AttackTax < StaticAbility
        def attack_tax_for(_attacker, target)
          target == controller && Magic::Storied.enduring_story?(controller) ? 1 : 0
        end
      end

      def static_abilities = [AttackTax]
    end
  end
end
