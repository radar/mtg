# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Goatnap do
  include_context "two player game"

  before { go_to_main_phase! }

  def goatnap(target)
    p1.add_mana(red: 3)
    p1.cast(card: Card("Goatnap")) do
      _1.auto_pay_mana
      _1.targeting(target)
    end
    game.stack.resolve!
    game.tick!
  end

  context "targeting an opponent's creature" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

    before do
      bears.tap!
      goatnap(bears)
    end

    it "gains control of it, untaps it and gives it haste" do
      expect(bears.controller).to eq(p1)
      expect(bears).to be_untapped
      expect(bears).to be_haste
      expect(bears).not_to be_summoning_sick
    end

    it "doesn't give a non-Goat +3/+0" do
      expect(bears.power).to eq(2)
    end

    it "gives control back at end of turn" do
      current_turn.end!
      current_turn.cleanup!

      expect(bears.controller).to eq(p2)
      expect(bears).not_to be_haste
    end
  end

  it "also gives a Goat +3/+0 until end of turn" do
    # A changeling is every creature type, Goat included.
    ResolvePermanent("Stalactite Dagger", owner: p2)
    goat = p2.creatures.find(&:token?)
    goatnap(goat)

    expect(goat.controller).to eq(p1)
    expect([goat.power, goat.toughness]).to eq([4, 1])
  end
end
