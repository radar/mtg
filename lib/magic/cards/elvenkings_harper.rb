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
          trigger_effect(:grant_keyword, target: target, keyword: :cant_be_blocked)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
