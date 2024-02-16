module Magic
  module Cards
    RoamingGhostlight = Creature("Roaming Ghostlight") do
      cost generic: 3, blue: 2
      type "Creature -- Spirit"
      power 3
      toughness 2
      keywords :flying

      enters_the_battlefield do
        game.add_choice(RoamingGhostlight::Choice.new(actor: actor))
      end
    end

    class RoamingGhostlight < Creature
      class Choice < Magic::Choice::Targeted
        def choices
          creatures.excluding_type(T::Creatures['Spirit'])
        end

        def choice_amount
          1
        end

        def resolve!(target:)
          game.add_effect(Effects::ReturnToOwnersHand.new(source: self, target: target))
        end
      end
    end
  end
end
