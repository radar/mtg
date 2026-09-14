# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ValakutExploration do
  include_context "two player game"

  let!(:valakut_exploration) { ResolvePermanent("Valakut Exploration", owner: p1) }

  it "exiles the top card of your library when a land you control enters" do
    top_card = Card("Mountain", owner: p1)
    p1.library.add(top_card)

    ResolvePermanent("Forest", owner: p1)

    expect(top_card.zone).to be_exile
    expect(valakut_exploration.exiled_cards).to eq([top_card])
  end

  it "does not trigger when an opponent's land enters" do
    ResolvePermanent("Forest", owner: p2)

    expect(valakut_exploration.exiled_cards).to be_empty
  end

  it "lets you play an exiled land while it remains exiled" do
    top_card = Card("Mountain", owner: p1)
    p1.library.add(top_card)
    ResolvePermanent("Forest", owner: p1)

    p1.play_land(land: top_card)

    expect(top_card.zone).to be_battlefield
  end

  it "lets you cast an exiled spell while it remains exiled" do
    top_card = Card("Lightning Bolt", owner: p1)
    p1.library.add(top_card)
    ResolvePermanent("Forest", owner: p1)

    p1.add_mana(red: 1)
    p1.cast(card: top_card) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    game.stack.resolve!

    expect(p2.life).to eq(17)
  end

  it "does nothing at the beginning of your end step with no exiled cards" do
    expect { current_turn.end! }.not_to(change { p2.life })
  end

  it "mills exiled cards and deals that much damage to each opponent at the beginning of your end step" do
    top_card_one = Card("Mountain", owner: p1)
    top_card_two = Card("Forest", owner: p1)
    p1.library.add(top_card_one)
    p1.library.add(top_card_two)

    ResolvePermanent("Forest", owner: p1)
    ResolvePermanent("Island", owner: p1)

    current_turn.end!

    expect(top_card_one.zone).to be_graveyard
    expect(top_card_two.zone).to be_graveyard
    expect(valakut_exploration.exiled_cards).to be_empty
    expect(p2.life).to eq(18)
  end

  it "does not trigger at the beginning of an opponent's end step" do
    top_card = Card("Mountain", owner: p1)
    p1.library.add(top_card)
    ResolvePermanent("Forest", owner: p1)

    game.next_turn

    expect { current_turn.end! }.not_to(change { p2.life })
    expect(valakut_exploration.exiled_cards).to eq([top_card])
  end
end
