require "spec_helper"

RSpec.describe Magic::Cards::KorvoldFaeCursedKing do
  include_context "two player game"

  it "sacrifices another permanent when it enters and rewards the sacrifice" do
    target = ResolvePermanent("Forest", owner: p1)
    ResolvePermanent("Mountain", owner: p1)
    hand_size = p1.hand.count
    korvold = ResolvePermanent("Korvold, Fae-Cursed King", owner: p1)
    game.resolve_choice!(target: target)
    game.settle!

    expect(target.card.zone).to be_graveyard
    expect(korvold.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
    expect(p1.hand.count).to eq(hand_size + 1)
  end
end