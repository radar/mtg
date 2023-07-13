module Magic
  module Cards
    class AnimalSanctuary < Land
      NAME = "Animal Sanctuary"
      TYPE_LINE = "Land"

      class ManaAbility < Magic::ManaAbility
        def costs
          [
            Costs::Tap.new(source),
          ]
        end

        def resolve!
          controller.add_mana(colorless: 1)
        end
      end

      class ActivatedAbility < Magic::ActivatedAbility
        def costs
          [
            Costs::Mana.new(colorless: 2),
            Costs::Tap.new(source),
          ]
        end

        def target_choices
          game.battlefield.creatures.by_any_type("Bird", "Cat", "Dog", "Goat", "Ox", "Snake")
        end

        def resolve!
          game.add_effect(Effects::AddCounter.new(source: source, counter_type: Counters::Plus1Plus1, choices: target_choices))
        end
      end

      def activated_abilities
        [ManaAbility, ActivatedAbility]
      end
    end
  end
end
