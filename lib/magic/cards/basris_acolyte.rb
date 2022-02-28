module Magic
  module Cards
    BasrisAcolyte = Creature("Basri's Acolyte") do
      type "Creature -- Cat Cleric"
      cost generic: 2, white: 2
      power 2
      toughness 3
      keywords :lifelink
    end

    class BasrisAcolyte < Creature
      def entered_the_battlefield!
        add_effect(
          "SingleTargetAndResolve",
          choices: battlefield.creatures,
          resolution: -> (target) {
            target.add_counter(Counters::Plus1Plus1)
            add_effect(
              "SingleTargetAndResolve",
              choices: battlefield.creatures - [target],
              resolution: -> (target) {
                target.add_counter(Counters::Plus1Plus1)
              }
            )
          }
        )
      end
    end
  end
end
