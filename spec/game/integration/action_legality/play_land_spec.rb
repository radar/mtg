require "spec_helper"

RSpec.describe Magic::Game, "action legality -- playing lands" do
  include_context "two player game"

  let(:forest) { Card("Forest", owner: p1) }
  let(:second_forest) { Card("Forest", owner: p1) }

  before do
    p1.hand.add(forest)
    p1.hand.add(second_forest)
  end

  it "can play a land from hand in the active player's main phase" do
    go_to_main_phase!

    p1.play_land(land: forest)

    expect(forest.zone).to be_battlefield
  end

  it "cannot play a land outside a main phase" do
    go_to_main_phase!
    current_turn.beginning_of_combat!

    expect { p1.play_land(land: forest) }.to raise_error(Magic::IllegalAction, /not a main phase/)
    expect(forest.zone).to be_hand
  end

  it "cannot play a land on the opponent's turn" do
    go_to_main_phase_for!(p2)

    expect { p1.play_land(land: forest) }.to raise_error(Magic::IllegalAction, /not .*P1.*turn/)
  end

  it "cannot play a land while the stack is not empty" do
    go_to_main_phase!
    bolt = Card("Lightning Bolt", owner: p1)
    p1.hand.add(bolt)
    p1.add_mana(red: 1)
    p1.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(p2) }

    expect { p1.play_land(land: forest) }.to raise_error(Magic::IllegalAction, /stack is not empty/)
  end

  it "cannot play a second land in the same turn" do
    go_to_main_phase!
    p1.play_land(land: forest)

    expect { p1.play_land(land: second_forest) }.to raise_error(Magic::IllegalAction, /cannot play any more lands/)
    expect(second_forest.zone).to be_hand
  end

  it "can play a second land after an effect grants an additional land drop" do
    go_to_main_phase!
    ResolvePermanent("Oracle of Mul Daya", owner: p1)
    p1.play_land(land: forest)
    game.settle!

    p1.play_land(land: second_forest)

    expect(second_forest.zone).to be_battlefield
  end

  it "can play another land on the next turn" do
    go_to_main_phase!
    p1.play_land(land: forest)
    game.next_turn
    game.next_turn
    go_to_main_phase!

    p1.play_land(land: second_forest)

    expect(second_forest.zone).to be_battlefield
  end

  it "cannot play a land from the library unless something permits it" do
    go_to_main_phase!
    top_card = Card("Forest", owner: p1)
    p1.library.add(top_card)

    expect { p1.play_land(land: top_card) }.to raise_error(Magic::IllegalAction, /not in a zone it can be played from/)
  end

  it "can play a land from the top of the library when a permanent permits it" do
    go_to_main_phase!
    ResolvePermanent("Oracle of Mul Daya", owner: p1)
    top_card = Card("Forest", owner: p1)
    p1.library.add(top_card)

    p1.play_land(land: top_card)

    expect(top_card.zone).to be_battlefield
  end

  it "cannot play a land from the graveyard" do
    go_to_main_phase!
    p1.hand.remove(forest)
    p1.graveyard.add(forest)

    expect { p1.play_land(land: forest) }.to raise_error(Magic::IllegalAction, /not in a zone it can be played from/)
  end
end
