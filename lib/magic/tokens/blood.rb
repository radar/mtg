module Magic
  module Tokens
    # "{1}, {T}, Discard a card, Sacrifice this token: Draw a card."
    Blood = Token.create("Blood") do
      type T::Artifact, "Blood"
      power 0
      toughness 0

      def activated_abilities = [self.class::Loot]
    end

    Blood.const_set(:Loot, Class.new(ActivatedAbility) do
      costs "{1}, {T}, Discard a card, Sacrifice {this}"

      def resolve!
        draw_card
      end
    end)
  end
end
