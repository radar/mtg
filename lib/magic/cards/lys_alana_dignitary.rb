module Magic
  module Cards
    LysAlanaDignitary = Creature("Lys Alana Dignitary") do
      cost generic: 1, green: 1
      creature_type("Elf Advisor")
      power 2
      toughness 3
    end

    class LysAlanaDignitary < Creature
      # As an additional cost to cast this spell, behold an Elf or pay {2}.
      def additional_costs
        [Costs::Behold.new(self, type: "Elf", or_mana: { generic: 2 })]
      end

      # {T}: Add {G}{G}. Activate only if there is an Elf card in your graveyard.
      class ManaAbility < Magic::TapManaAbility
        def requirements_met?
          controller.graveyard.by_type("Elf").any?
        end

        def resolve!
          controller.add_mana(green: 2)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
