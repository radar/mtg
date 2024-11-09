require "spec_helper"

RSpec.describe Magic::Cards::EidolonOfBlossoms do
  include_context "two player game"

  context "when it enters" do
    subject { Card("Eidolon of Blossoms") }

    it "draws a card" do
      expect(p1).to receive(:draw!)

      p1.add_mana(green: 4)
      p1.cast(card: subject) do
        _1.auto_pay_mana
      end

      game.stack.resolve!
    end
  end

  context "when its already on the field and another enchantment enters" do
    let(:nine_lives) { Card("Nine Lives") }

    subject! { ResolvePermanent("Eidolon of Blossoms") }

    it "draws a card" do
      expect(p1).to receive(:draw!)

      p1.add_mana(white: 3)
      p1.cast(card: nine_lives) do
        _1.auto_pay_mana
      end

      game.stack.resolve!
    end
  end
end
