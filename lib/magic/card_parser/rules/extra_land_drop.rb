# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "You may play an additional land on each of your turns." -> the
      # `additional_lands_per_turn 1` class macro (`Player#max_lands_per_turn` adds it up).
      class ExtraLandDrop < Data.define
        include Rule

        LINE = /\AYou may play an additional land on each of your turns\.?\z/i

        def self.parse(line)
          new if LINE.match?(line)
        end

        def kinds = PERMANENT_KINDS
        def body_source = "additional_lands_per_turn 1\n"
      end
    end
  end
end
