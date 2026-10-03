# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ExemplarOfLight do
  include_context "two player game"

  let!(:exemplar) { ResolvePermanent("Exemplar Of Light", owner: p1) }

  it "is a 3/3 Angel with flying" do
    expect([exemplar.power, exemplar.toughness]).to eq([3, 3])
    expect(exemplar).to be_flying
  end

  it "gets a +1/+1 counter and draws a card when you gain life" do
    expect { p1.gain_life(2); game.settle! }.to change { p1.hand.count }.by(1)

    expect(exemplar.power).to eq(4)
  end

  it "draws only once each turn, though it gets a counter every time" do
    expect do
      p1.gain_life(1)
      game.settle!
      p1.gain_life(1)
      game.settle!
    end.to change { p1.hand.count }.by(1)

    expect(exemplar.power).to eq(5)
  end

  it "draws again on a later turn" do
    p1.gain_life(1)
    game.settle!
    current_turn.end!
    current_turn.cleanup!
    resolve_cleanup_discards!
    hand = p1.hand.count
    p1.gain_life(1)
    game.settle!

    expect(p1.hand.count).to eq(hand + 1)
  end

  it "does nothing when an opponent gains life" do
    expect { p2.gain_life(3); game.settle! }.not_to(change { p1.hand.count })

    expect(exemplar.power).to eq(3)
  end

  it "does not draw for a +1/+1 counter on another creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)

    expect { bears.trigger_effect(:add_counter, counter_type: "+1/+1", target: bears, amount: 1); game.settle! }
      .not_to(change { p1.hand.count })
  end
end
