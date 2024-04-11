require "spec_helper"

RSpec.describe Magic::Cards::LifeGoesOn do
  include_context "two player game"
  let(:life_goes_on) { Card("Life Goes On") }
  context "when no creature died" do
    it "player gains 4 life" do
      p1.add_mana(green: 1)
      p1.cast(card: life_goes_on) do
        _1.pay_mana(green: 1)
      end

      game.tick!
      expect(p1.life).to eq(24)
    end
  end

  context "when a creature died" do
    let(:creature) { ResolvePermanent("Wood Elves") }

    before do
      creature.sacrifice!
    end

    it "player gains 8 life" do
      p1.add_mana(green: 1)
      p1.cast(card: life_goes_on) do
        _1.pay_mana(green: 1)
      end

      game.tick!
      expect(p1.life).to eq(28)
    end
  end
end
