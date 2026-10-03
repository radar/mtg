# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Reveal cards from the top of your library until you reveal a creature card. Put that card into your
      # hand and the rest on the bottom of your library in a random order." (Spinner of Souls)
      class RevealUntil < Data.define(:type)
        include Effect

        LINE = /\AReveal cards from the top of your library until you reveal an? (?<type>[a-z]+|nonland) card\. Put that card into your hand and the rest on the bottom of your library in a random order\.?\z/i

        def self.parse(text)
          new(type: $~[:type].downcase) if LINE.match(text)
        end

        def check = type == "nonland" ? "!_1.land?" : "_1.type?(#{type.capitalize.inspect})"

        def resolve_call
          <<~RUBY.chomp
            library = controller.library
            found = library.find { #{check} }
            revealed = library.take_while { !_1.equal?(found) }
            trigger_effect(:reveal_cards, target: [*revealed, found].compact)
            found&.move_to_hand!
            revealed.shuffle.each do |card|
              library.remove(card)
              library.push(card)
            end
          RUBY
        end
      end
    end
  end
end
