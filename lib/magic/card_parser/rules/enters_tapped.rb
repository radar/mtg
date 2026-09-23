# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "~ enters tapped." / "~ enters the battlefield tapped."
      class EntersTapped < Data.define
        include Rule

        LINE = /\A~ enters(?: the battlefield)? tapped\.?\z/

        def self.parse(line)
          new if LINE.match?(line)
        end

        def body_source = "enters_tapped\n"
      end
    end
  end
end
