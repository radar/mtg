require "spec_helper"

RSpec.describe Magic::Cards::DeepchannelDuelist do
  include_context "two player game"

  let!(:duelist) { ResolvePermanent("Deepchannel Duelist", owner: p1) }
  let!(:merfolk) { ResolvePermanent("Pestered Wellguard", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "is a 2/2" do
    expect([duelist.power, duelist.toughness]).to eq([2, 2])
  end

  it "gives other Merfolk you control +1/+1" do
    game.tick!

    expect([merfolk.power, merfolk.toughness]).to eq([4, 3])
    expect([duelist.power, duelist.toughness]).to eq([2, 2])
    expect([bears.power, bears.toughness]).to eq([2, 2])
  end

  it "untaps a target Merfolk you control at the beginning of your end step" do
    go_to_main_phase!
    merfolk.tap!
    duelist.tap!
    current_turn.end!

    expect(game.choices.last.choices).to contain_exactly(duelist, merfolk)
    game.resolve_choice!(target: merfolk)

    expect(merfolk).to be_untapped
    expect(duelist).to be_tapped
  end
end
