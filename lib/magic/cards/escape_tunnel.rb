module Magic
  module Cards
    EscapeTunnel = Card("Escape Tunnel") do
      type "Land"
    end

    class EscapeTunnel < Card
      class BasicLandChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :battlefield, enters_tapped: true, filter: Filter[:basic_lands],
                prompt: "Search your library for a basic land card. It enters the battlefield tapped.")
        end
      end

      class SearchAbility < Magic::ActivatedAbility
        costs "{T}, Sacrifice {this}"

        def resolve!
          game.add_choice(BasicLandChoice.new(actor: source))
        end
      end

      # "{T}, Sacrifice this land: Target creature with power 2 or less can't be blocked this turn."
      class UnblockableAbility < Magic::ActivatedAbility
        costs "{T}, Sacrifice {this}"

        def target_choices
          battlefield.creatures.select { |creature| creature.power <= 2 }
        end

        def resolve!(target:)
          target.grant_keyword(Keywords::CANT_BE_BLOCKED)
        end
      end

      def activated_abilities = [SearchAbility, UnblockableAbility]
    end
  end
end