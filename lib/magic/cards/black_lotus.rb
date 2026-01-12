module Magic
  module Cards
    BlackLotus = Artifact("Black Lotus") do
      cost generic: 0
    end

    class BlackLotus < Artifact
      class ManaAbility < Magic::ManaAbility
        costs "{T}, Sacrifice {this}"
        choices :all

        def resolve!
          @choice ||= choices.first if choices.length == 1

          raise "Invalid choice made for mana ability. Choice: #{choice}, Choices: #{choices}" unless choices.include?(choice)
          source.controller.add_mana(choice => 3)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
