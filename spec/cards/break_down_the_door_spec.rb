# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BreakDownTheDoor do
  include_context "two player game"

  let(:spell) { Card("Break Down The Door", owner: p1).tap { p1.hand.add(_1) } }

  before { go_to_main_phase! }

  def cast_with(mode, target = nil)
    p1.add_mana(green: 3)
    p1.cast(card: spell) do |action|
      action.pay_mana(generic: { green: 2 }, green: 1)
      action.choose_mode(mode) { target ? _1.targeting(target) : _1 }
    end
    game.stack.resolve!
    game.settle!
  end

  it "exiles target artifact" do
    sol_ring = ResolvePermanent("Sol Ring", owner: p2)
    cast_with(described_class::ExileArtifact, sol_ring)

    expect(game.exile.cards).to include(sol_ring.card)
  end

  it "exiles target enchantment" do
    sanctum = ResolvePermanent("Sanctum Of Calm Waters", owner: p2)
    cast_with(described_class::ExileEnchantment, sanctum)

    expect(game.exile.cards).to include(sanctum.card)
  end

  it "manifests dread" do
    cast_with(described_class::ManifestDreadMode)
    game.resolve_choice!(target: game.choices.last.choices.first)

    expect(p1.permanents.count(&:face_down?)).to eq(1)
  end

  it "can't exile an artifact with the enchantment mode" do
    sol_ring = ResolvePermanent("Sol Ring", owner: p2)

    expect { cast_with(described_class::ExileEnchantment, sol_ring) }.to raise_error(StandardError)
  end
end
