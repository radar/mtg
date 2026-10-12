module Magic
  module Cards
    ElvenkingsHarper = Creature("Elvenking's Harper") do
      cost generic: 1, blue: 1
      creature_type("Elf Bard")
      power 2
      toughness 2
    end

    class ElvenkingsHarper < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{4}{U}"

        def target_choices = battlefield.creatures

        def resolve!(target:)
          give_keyword(target, :cant_be_blocked)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
