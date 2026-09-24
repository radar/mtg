require "spec_helper"

RSpec.describe Magic::Cards::DreamSeizer do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def minus_counters(permanent) = permanent.counters.of_type(Magic::Counters::Minus1Minus1).count

  it "is a 3/2 flyer" do
    seizer = ResolvePermanent("Dream Seizer", owner: p1)
    game.skip_choice!

    expect([seizer.power, seizer.toughness]).to eq([3, 2])
    expect(seizer).to be_flying
  end

  it "may blight 1 when it enters; if you do, each opponent discards a card" do
    seizer = ResolvePermanent("Dream Seizer", owner: p1)
    game.resolve_choice!
    expect(game.choices.last.choices).to contain_exactly(bears, seizer)

    game.resolve_choice!(target: bears)
    expect(minus_counters(bears)).to eq(1)

    discard = game.choices.last
    expect(discard).to be_a(Magic::Choice::Discard)
    expect(discard.player).to eq(p2)
    expect { game.resolve_choice!(card: p2.hand.first) }.to change { p2.hand.count }.by(-1)
  end

  it "does nothing when you decline" do
    ResolvePermanent("Dream Seizer", owner: p1)
    expect { game.skip_choice! }.not_to(change { p2.hand.count })
    expect(minus_counters(bears)).to eq(0)
  end
end
