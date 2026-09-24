module Magic
  module Tokens
    # "{2}, {T}, Sacrifice this artifact: You gain 3 life."
    Food = Token.create("Food") do
      type T::Artifact, "Food"
      power 0
      toughness 0

      def activated_abilities = [self.class::GainLife]
    end

    Food.const_set(:GainLife, Class.new(ActivatedAbility) do
      costs "{2}, {T}, Sacrifice {this}"

      def resolve!
        trigger_effect(:gain_life, life: 3)
      end
    end)
  end
end
