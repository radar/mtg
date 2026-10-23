# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CollectiveResistance do
  include_context "two player game"

  let(:card) { Card("Collective Resistance", owner: p1) }
  let!(:artifact) { ResolvePermanent("Sol Ring", owner: p2) }
  let!(:enchantment) { ResolvePermanent("Sylvan Library", owner: p2) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before { p1.hand.add(card) }

  # Escalate raises the cost as each extra mode is chosen, so the modes come before the payment.
  def cast(modes)
    p1.add_mana(green: 2 + modes.size - 1)
    p1.cast(card: card) do |action|
      modes.each { |mode, target| action.choose_mode(mode) { _1.targeting(target) } }
      action.pay_mana(green: modes.size, generic: { green: 1 })
    end
    game.stack.resolve!
    game.settle!
  end

  it "destroys target artifact" do
    cast([[described_class::DestroyArtifact, artifact]])

    expect(game.battlefield.cards).not_to include(artifact)
    expect(game.battlefield.cards).to include(enchantment)
  end

  it "destroys target enchantment" do
    cast([[described_class::DestroyEnchantment, enchantment]])

    expect(game.battlefield.cards).not_to include(enchantment)
    expect(game.battlefield.cards).to include(artifact)
  end

  it "gives target creature hexproof and indestructible until end of turn" do
    cast([[described_class::ProtectCreature, bears]])

    expect(bears).to have_keyword(:hexproof)
    expect(bears).to have_keyword(:indestructible)
  end

  it "costs {G} more for each mode beyond the first" do
    cast([
      [described_class::DestroyArtifact, artifact],
      [described_class::DestroyEnchantment, enchantment],
      [described_class::ProtectCreature, bears]
    ])

    expect(game.battlefield.cards).not_to include(artifact, enchantment)
    expect(bears).to have_keyword(:hexproof)
    expect(p1.mana_pool.values.sum).to eq(0)
  end

  it "can't cast two modes for the base cost" do
    p1.add_mana(green: 2)

    expect do
      p1.cast(card: card) do |action|
        action.choose_mode(described_class::DestroyArtifact) { _1.targeting(artifact) }
        action.choose_mode(described_class::ProtectCreature) { _1.targeting(bears) }
        action.pay_mana(green: 1, generic: { green: 1 })
      end
    end.to raise_error(StandardError, /cost|pay/i)
  end
end
