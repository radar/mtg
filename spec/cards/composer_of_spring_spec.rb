require "spec_helper"

RSpec.describe Magic::Cards::ComposerOfSpring do
  include_context "two player game"

  subject { ResolvePermanent("Composer of Spring") }

  context "when an enchantment enters under your control" do
    it "may put a land from your hand into play tapped" do
      subject

      p1.add_mana(white: 3)
      p1.cast(card: Card("Nine Lives")) do
        _1.pay_mana(generic: { white: 1 }, white: 2)
      end

      game.stack.resolve!

      expect(game.choices.last).to be_a(Magic::Cards::ComposerOfSpring::LandChoice)
      expect(game.choices.last.choices).to eq(p1.hand.lands)

      chosen_land = p1.hand.lands.first

      game.resolve_choice!(target: chosen_land)

      game.stack.resolve!

      expect(game.battlefield.by_name("Forest").count).to eq(1)
    end

    context "when there are 6 or more enchantments" do
      before do
        6.times { ResolvePermanent("Nine Lives", owner: p1) }

        p1.hand.add(Card("Wood Elves"))
      end

      it "may put a land or creature from your hand into play tapped" do
        subject

        p1.add_mana(white: 3)
        p1.cast(card: Card("Nine Lives")) do
          _1.pay_mana(generic: { white: 1 }, white: 2)
        end

        game.stack.resolve!

        expect(game.choices.last).to be_a(Magic::Cards::ComposerOfSpring::LandOrCreatureChoice)
        expect(game.choices.last.choices).to eq(p1.hand.lands + p1.hand.creatures)

        chosen_creature = p1.hand.creatures.first

        game.resolve_choice!(target: chosen_creature)

        game.stack.resolve!

        expect(game.battlefield.by_name(chosen_creature.name).count).to eq(1)
      end


    end
  end
end
