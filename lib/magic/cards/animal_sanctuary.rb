module Magic
  module Cards
    class AnimalSanctuary < Land
      NAME = "Animal Sanctuary"
      TYPE_LINE = "Land"

      class ManaAbility < Magic::ManaAbility
        costs "{T}"

        def resolve!
          controller.add_mana(generic: 1)
        end
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}, {T}"

        def target_choices
          creatures.by_any_type(
            Types::Creatures["Bird"],
            Types::Creatures["Cat"],
            Types::Creatures["Dog"],
            Types::Creatures["Goat"],
            Types::Creatures["Ox"],
            Types::Creatures["Snake"],
          )
        end

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: Counters::Plus1Plus1, target: target)
        end
      end

      def activated_abilities
        [ManaAbility, ActivatedAbility]
      end
    end
  end
end
