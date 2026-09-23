# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Choose any number of artifact tokens and/or creature tokens you control with
      # different names. For each of them, create a token that's a copy of it."
      class CopyTokens < Data.define
        include Effect

        LINE = /\AChoose any number of artifact tokens and\/or creature tokens you control with different names\. For each of them, create a token that's a copy of it\.?\z/i

        def self.parse(text)
          new if LINE.match?(text)
        end

        def resolve_call = "game.add_choice(Magic::Choice::CopyTokens.new(actor: self))"
      end
    end
  end
end
