require "spec_helper"

RSpec.describe Magic::Cards::GutsplitterGang do
  include_context "two player game"

  let!(:gang) { ResolvePermanent("Gutsplitter Gang", owner: p1) }

  def minus_counters(permanent) = permanent.counters.of_type(Magic::Counters::Minus1Minus1).count

  it "is a 6/6" do
    expect([gang.power, gang.toughness]).to eq([6, 6])
  end

  it "loses you 3 life at the beginning of your first main phase if you don't blight" do
    go_to_main_phase!
    game.skip_choice!

    expect(p1.life).to eq(17)
    expect(minus_counters(gang)).to eq(0)
  end

  it "blights 2 instead, losing no life" do
    go_to_main_phase!
    game.resolve_choice!
    game.resolve_choice!(target: gang)

    expect(minus_counters(gang)).to eq(2)
    expect(p1.life).to eq(20)
  end

  it "doesn't trigger in the opponent's first main phase" do
    go_to_main_phase_for!(p2)

    expect(game.choices).to be_empty
    expect(p1.life).to eq(20)
  end
end
