# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Exile target creature card from a graveyard that was put there this turn. Create a token that's a copy
      # of it, except it's a Nightmare in addition to its other types. Then exile all other Nightmare tokens you
      # control." (Abyssal Harvester). "Put there this turn" reads the turn's event log for the card entering a
      # graveyard (from the battlefield, hand, library, ...). The token is a copy of the card.
      class CopyGraveyardCreatureAsType < Data.define(:type)
        include Effect

        LINE = /\AExile target creature card from a graveyard that was put there this turn\. Create a token that's a copy of it, except it's an? (?<type>[A-Z][\w-]*) in addition to its other types\. Then exile all other \k<type> tokens you control\.?\z/

        def self.parse(text)
          return unless (m = LINE.match(text)) && Types::Creatures.values.include?(m[:type])

          new(type: m[:type])
        end

        def target_choices
          "game.graveyard_cards.by_any_type(\"Creature\").select { |card| " \
            "game.current_turn.events.any? { |e| e.is_a?(Events::CardEnteredZone) && e.card == card && e.to.graveyard? } }"
        end

        def resolve_call
          <<~RUBY.chomp
            target.exile!
            copy = Permanent.resolve(game: game, owner: controller, card: target, token: true, copy: true, cast: false)
            copy.add_types(T::Creatures[#{type.inspect}], until_eot: false)
            controller.permanents.select { _1.token? && _1.type?(#{type.inspect}) && _1 != copy }.each(&:exile!)
          RUBY
        end
      end
    end
  end
end
