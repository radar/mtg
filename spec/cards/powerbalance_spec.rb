# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Powerbalance do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:powerbalance) { ResolvePermanent("Powerbalance", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def top_card_for_p1(name)
    card = Card(name, owner: p1)
    p1.library.add(card)
    card
  end

  def opponent_casts_bolt!
    p2.add_mana(red: 1)
    p2.cast(card: Card("Lightning Bolt", owner: p2)) do |action|
      action.targeting(p1)
      action.auto_pay_mana
    end
    game.settle!
  end

  it "does nothing when you cast a spell yourself" do
    p1.add_mana(red: 1)
    p1.cast(card: Card("Lightning Bolt", owner: p1)) do |action|
      action.targeting(p2)
      action.auto_pay_mana
    end
    game.settle!

    expect(game.choices).to be_empty
  end

  it "offers a reveal when an opponent casts a spell" do
    opponent_casts_bolt!

    expect(game.choices.last).to be_a(described_class::MayReveal)
  end

  it "does nothing if you decline to reveal" do
    top = top_card_for_p1("Lightning Bolt")
    opponent_casts_bolt!
    game.skip_choice!

    expect(game.choices).to be_empty
    expect(top.zone).to eq(p1.library)
  end

  context "when the revealed card has the same mana value" do
    let!(:top) { top_card_for_p1("Lightning Bolt") }

    before do
      opponent_casts_bolt!
      game.resolve_choice!
    end

    it "offers a free cast, which puts it on the stack with no mana paid" do
      expect(game.choices.last).to be_a(described_class::MayCast)
      game.resolve_choice!

      expect(game.stack.spells.map(&:card)).to include(top)
      expect(p1.mana_pool.values.sum).to eq(0)
    end

    it "leaves the card on top if you decline to cast it" do
      game.skip_choice!

      expect(top.zone).to eq(p1.library)
      expect(p1.library.first).to eq(top)
    end
  end

  it "offers no cast when the mana values differ" do
    top = top_card_for_p1("Grizzly Bears")
    opponent_casts_bolt!
    game.resolve_choice!

    expect(game.choices).to be_empty
    expect(top.zone).to eq(p1.library)
  end

  it "offers no cast when the revealed card is a land" do
    top_card_for_p1("Forest")
    opponent_casts_bolt!
    game.resolve_choice!

    expect(game.choices).to be_empty
  end
end
