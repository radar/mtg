module Magic
  module Cards
    RunedHalo = Enchantment("Runed Halo") do
      cost white: 2

      enters_the_battlefield do
        game.choices.add(RunedHalo::Choice.new(actor: actor))
      end
    end

    class RunedHalo < Enchantment
      class Choice < Magic::Choice::CardName
        def resolve!(choice: nil)
          actor.protections << Protection.new(condition: -> (c) { choice == c.class }, protects_player: true)
        end
      end
    end
  end
end
