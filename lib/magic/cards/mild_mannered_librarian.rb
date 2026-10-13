module Magic
  module Cards
    MildManneredLibrarian = Creature("Mild-Mannered Librarian") do
      cost green: 1
      creature_type("Human")
      power 1
      toughness 1
    end

    class MildManneredLibrarian < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{3}{G}"

        activate_only_once

        def resolve!
          source.become_creature_type!(T::Creatures["Werewolf"])
          add_counter("+1/+1", to: source, amount: 2)
          draw_card
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
