module Magic
  module Tokens
    # "Shard": an enchantment token with "{2}, Sacrifice this token: Scry 1, then draw a card."
    Shard = Token.create("Shard") do
      type T::Enchantment, "Shard"
      power 0
      toughness 0

      def activated_abilities = [self.class::ScryAndDraw]
    end

    # Scry first; the draw waits until the scry has been answered.
    Shard.const_set(:ScryThenDraw, Class.new(Magic::Choice::Scry) do
      def resolve!(**args)
        super
        chooser.draw!
      end
    end)

    Shard.const_set(:ScryAndDraw, Class.new(ActivatedAbility) do
      costs "{2}, Sacrifice {this}"

      def resolve!
        game.choices.add(Shard::ScryThenDraw.new(actor: source, amount: 1))
      end
    end)
  end
end
