module Magic
  module Cards
    DaybreakCharger = Creature("Daybreak Charger") do
      cost generic: 1, white: 1
      creature_type("Unicorn")
      power 3
      toughness 1

      enters_the_battlefield do
        game.choices.add(DaybreakCharger::Choice.new(source: permanent))
      end
    end

    class DaybreakCharger < Creature
      class Choice < Magic::Choice
        def choices
          Magic::Targets::Choices.new(
            choices: battlefield.creatures,
            amount: 1,
          )
        end

        def resolve!(target:)
          source.trigger_effect(:modify_power_toughness, power: 2, target: target)
        end
      end
    end
  end
end
