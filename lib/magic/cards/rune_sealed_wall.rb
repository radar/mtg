module Magic
  module Cards
    RuneSealedWall = Creature("Rune-Sealed Wall") do
      cost generic: 2, blue: 1
      artifact_creature_type("Wall")
      keywords :defender
      power 0
      toughness 6
    end

    class RuneSealedWall < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}"

        def resolve!
          game.choices.add(Magic::Choice::Surveil.new(actor: source, amount: 1))
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
