# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SmaugTheGreatCalamity do
  include_context "two player game"

  let(:smaug) { Card("Smaug The Great Calamity", owner: p1) }

  before do
    p1.hand.add(smaug)
    go_to_main_phase!
  end

  it "is a 5/5 flying Dragon" do
    permanent = ResolvePermanent("Smaug The Great Calamity", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([5, 5])
    expect(permanent).to have_keyword(:flying)
    expect(permanent).to be_legendary
  end

  it "can be cast as a creature for {5}{R}{R}" do
    p1.add_mana(red: 7)
    p1.cast(card: smaug) { |a| a.pay_mana(generic: { red: 5 }, red: 2) }
    game.stack.resolve!

    expect(p1.creatures.map(&:name)).to include("Smaug, the Great Calamity")
  end

  describe "adventure: Spew Flame" do
    let!(:victim) { ResolvePermanent("Ordinary Bear", owner: p2) }

    def spew_flame(target)
      p1.add_mana(red: 5)
      p1.cast(card: smaug, adventure: true) do |a|
        a.pay_mana(generic: { red: 4 }, red: 1)
        a.targeting(target)
      end
      game.stack.resolve!
      game.settle!
    end

    it "deals 5 damage to target creature" do
      spew_flame(victim)

      expect(victim.card.zone).to be_graveyard
    end

    it "exiles the card so Smaug can be cast later" do
      spew_flame(victim)

      expect(smaug.zone).to be_exile
      expect(smaug.on_adventure).to be(true)
    end

    it "lets you cast Smaug from exile afterwards" do
      spew_flame(victim)
      go_to_main_phase!
      p1.add_mana(red: 7)
      p1.cast(card: smaug) { |a| a.pay_mana(generic: { red: 5 }, red: 2) }
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Smaug, the Great Calamity")
    end
  end
end
