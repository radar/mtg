module Magic
  module Cards
    EternalWitness = Creature("Eternal Witness") do
      cost green: 1, generic: 2
      power 2
      toughness 1
      creature_type "Human Shaman"

      enters_the_battlefield do
        game.add_choice(EternalWitness::Choice.new(actor: actor))
      end
    end

    class EternalWitness < Creature
      class Choice < Magic::Choice::May
        def choices
          controller.graveyard
        end

        def resolve!(target:)
          target.move_to_hand!
        end
      end
    end
  end
end
