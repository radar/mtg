# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UrenisRebuff do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Ureni's Rebuff", owner: p1) }
  let!(:target) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "returns target creature to its owner's hand" do
    p1.add_mana(blue: 2)
    p1.cast(card: card) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1).targeting(target) }
    game.stack.resolve!

    expect(p2.hand).to include(target.card)
    expect(card.zone).to be_graveyard
  end

  it "can be harmonized from the graveyard for {5}{U}, then is exiled" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.graveyard.add(card)
    p1.add_mana(blue: 4)

    p1.cast(card: card, harmonize: true) do |a|
      a.harmonize_tap(bear)
      a.pay_mana(generic: { blue: 3 }, blue: 1).targeting(target)
    end
    game.stack.resolve!

    expect(p2.hand).to include(target.card)
    expect(card.zone).to be_exile
  end
end
