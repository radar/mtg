require "spec_helper"

RSpec.describe Magic::Cards::RakdosCharm do
  include_context "two player game"

  it "offers all three modes" do
    expect(described_class::MODES).to eq([
      described_class::ExileGraveyard,
      described_class::DestroyArtifact,
      described_class::DamageEachCreature,
    ])
  end

  it "destroys a target artifact with the second mode" do
    artifact = ResolvePermanent("Mind Stone", owner: p2)
    charm = Card("Rakdos Charm", owner: p1)
    p1.hand.add(charm)
    p1.add_mana(black: 1, red: 1)
    p1.cast(card: charm) do |action|
      action.pay_mana(black: 1, red: 1)
      action.choose_mode(described_class::DestroyArtifact) { _1.targeting(artifact) }
    end
    game.stack.resolve!

    expect(artifact.card.zone).to be_graveyard
  end
end