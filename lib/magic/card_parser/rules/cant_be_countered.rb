# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "This spell can't be countered." -> the cant_be_countered DSL call.
      class CantBeCountered < Data.define
        include Rule

        LINE = /\A~ can't be countered\.?\z/

        def self.parse(line)
          new if LINE.match?(line)
        end

        def dsl_lines = ["cant_be_countered"]
      end
    end
  end
end
