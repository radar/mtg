# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # Exiling cards out of graveyards (graveyard hate), chosen as targets:
      #
      #   Exile up to one target card from a graveyard.
      #   Exile target card from an opponent's graveyard.
      #   Exile target player's graveyard.
      #   Exile up to two target cards from a single graveyard. If at least one creature card was
      #   exiled this way, each opponent loses 2 life and you gain 2 life.
      #
      # "Up to N" targets resolve with `targets` (N > 1, a trigger's `0..N` choice); "a single
      # graveyard" is checked on resolution (all the targets must share a zone), since a choice
      # can't express "all from one list". The trailing drain sentence is part of this effect,
      # because it needs to know which cards were exiled.
      class ExileFromGraveyards < Data.define(:whose, :player_graveyard, :max_targets, :optional, :single, :drain)
        include Effect

        POOLS = { "a" => "game.graveyard_cards", "an opponent's" => "game.opponents(controller).flat_map { _1.graveyard.cards }",
                  "your" => "controller.graveyard.cards" }.freeze
        LINE = /\AExile (?:target player's graveyard|(?<quant>target|up to (?<count>\w+) target) cards? from (?<single>a single|an opponent's|a|your) graveyard)\.?(?: If at least one creature card was exiled this way, each opponent loses (?<lose>\d+) life and you gain (?<gain>\d+) life\.?)?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))
          return new(whose: "a", player_graveyard: true, max_targets: 1, optional: false, single: false, drain: nil) unless m[:quant]

          drain = [m[:lose].to_i, m[:gain].to_i] if m[:lose]
          count = m[:count] ? Number.parse(m[:count]) : 1
          new(whose: m[:single].downcase.sub("a single", "a"), player_graveyard: false, max_targets: count, optional: !m[:count].nil?,
              single: m[:single].downcase == "a single", drain:)
        end

        def target_choices = player_graveyard ? "game.players" : POOLS.fetch(whose)
        def optional_target? = optional

        def resolve_call
          return "[*target.graveyard.cards].each { trigger_effect(:exile, target: _1) }" if player_graveyard
          return "trigger_effect(:exile, target: target)" if max_targets == 1

          lines = []
          lines << "raise ArgumentError, \"targets must all be in a single graveyard\" unless targets.map(&:zone).uniq.size <= 1" if single
          lines << "exiled = targets.uniq" if drain
          lines << "targets.uniq.each { trigger_effect(:exile, target: _1) }"
          if drain
            lines << "if exiled.any?(&:creature?)"
            lines << "  game.opponents(controller).each { trigger_effect(:lose_life, target: _1, life: #{drain[0]}) }"
            lines << "  trigger_effect(:gain_life, target: controller, life: #{drain[1]})"
            lines << "end"
          end
          lines.join("\n")
        end
      end
    end
  end
end
