module Magic
  module Cards
    RaggedPlaymate = Creature("Ragged Playmate") do
      cost generic: 1, red: 1
      artifact_creature_type "Toy"
      power 2
      toughness 2
    end

    class RaggedPlaymate < Creature
      # "{1}, {T}: Target creature with power 2 or less can't be blocked this turn."
      class UnblockableAbility < Magic::ActivatedAbility
        costs "{1}, {T}"

        def target_choices
          battlefield.creatures.select { |creature| creature.power <= 2 }
        end

        def resolve!(target:)
          target.grant_keyword(Keywords::CANT_BE_BLOCKED)
        end
      end

      def activated_abilities = [UnblockableAbility]
    end
  end
end
