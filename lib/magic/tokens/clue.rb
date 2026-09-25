module Magic
  module Tokens
    # "{2}, Sacrifice this artifact: Draw a card."
    Clue = Token.create("Clue") do
      type T::Artifact, "Clue"
      power 0
      toughness 0

      def activated_abilities = [self.class::Investigate]
    end

    Clue.const_set(:Investigate, Class.new(ActivatedAbility) do
      costs "{2}, Sacrifice {this}"

      def resolve!
        trigger_effect(:draw_cards, number_to_draw: 1)
      end
    end)
  end
end
