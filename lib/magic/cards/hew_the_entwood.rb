module Magic
  module Cards
    HewTheEntwood = Sorcery("Hew the Entwood") do
      cost generic: 3, red: 2
    end

    class HewTheEntwood < Sorcery
      # "Choose any number of artifact and/or land cards revealed this way. Put all nonland cards chosen this way onto
      # the battlefield, then put all land cards chosen this way onto the battlefield tapped, then put the rest on the
      # bottom of your library in a random order."
      class PutRevealed < Magic::Choice
        attr_reader :revealed, :choices

        def initialize(actor:, revealed:)
          super(actor: actor)
          @revealed = revealed
          @choices = revealed.select { _1.type?("Artifact") || _1.type?("Land") }
        end

        def prompt = "Choose any number of artifact and/or land cards."

        def resolve!(choices: [])
          chosen = Array(choices).uniq
          invalid = chosen - self.choices
          raise ArgumentError, "#{invalid.first.name} is not an artifact or land card revealed this way" if invalid.any?

          lands, nonlands = chosen.partition { _1.type?("Land") }
          nonlands.each { enter(_1, tapped: false) }
          lands.each { enter(_1, tapped: true) }

          (revealed - chosen).shuffle.each do |card|
            controller.library.remove(card)
            controller.library.push(card)
          end
        end

        def decline! = resolve!(choices: [])

        private

        def enter(card, tapped:)
          Magic::Permanent.put_onto_battlefield(game: game, card: card, owner: card.owner, controller: controller, enters_tapped: tapped)
        end
      end

      # "Sacrifice any number of lands. Reveal the top X cards of your library, where X is the number of lands
      # sacrificed this way." Declining sacrifices none.
      class SacrificeLands < Magic::Choice
        def prompt = "Sacrifice any number of lands."

        def choices = controller.permanents.select { _1.type?("Land") }

        def resolve!(sacrifices: [])
          chosen = Array(sacrifices).uniq
          invalid = chosen - choices
          raise ArgumentError, "choose only lands you control" if invalid.any?

          chosen.each(&:sacrifice!)
          revealed = controller.library.first(chosen.count)
          return if revealed.empty?

          reveal_cards revealed
          game.add_choice(PutRevealed.new(actor: actor, revealed: revealed))
        end

        def decline! = resolve!(sacrifices: [])
      end

      def resolve!
        game.add_choice(SacrificeLands.new(actor: self))
        super
      end
    end
  end
end
