module Magic
  module Cards
    ThornvaultForager = Creature("Thornvault Forager") do
      cost generic: 1, green: 1
      creature_type("Squirrel Ranger")
      power 2
      toughness 2
    end

    class ThornvaultForager < Creature
      class GreenManaAbility < Magic::TapManaAbility
        choices :green
      end

      # {T}, Forage: Add two mana in any combination of colors.
      class ForageManaAbility < Magic::ManaAbility
        costs "{T}, Forage"
        choices :all

        # Two colors, answered as `choose(%i[green blue])`.
        def resolve!
          raise "Invalid choice made for mana ability. Choice: #{choice}, Choices: #{choices}" unless choice.is_a?(Array) && choice.size == 2 && (choice - choices).empty?

          choice.each { |color| source.controller.add_mana(color => 1) }
        end
      end

      # {3}{G}, {T}: Search your library for a Squirrel card, reveal it, put it into your hand, then shuffle.
      class SearchAbility < Magic::ActivatedAbility
        costs "{3}{G}, {T}"

        def resolve!
          game.choices.add(Magic::Choice::SearchLibrary.new(actor: source, filter: ->(card) { card.type?("Squirrel") }, to_zone: :hand, reveal: true))
        end
      end

      def activated_abilities = [GreenManaAbility, ForageManaAbility, SearchAbility]
    end
  end
end
