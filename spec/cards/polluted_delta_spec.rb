# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PollutedDelta do
  include_context "two player game"

  let!(:delta) { ResolvePermanent("Polluted Delta", owner: p1) }
  let!(:island) { Card("Island", owner: p1).tap { p1.library.add(_1) } }
  let!(:swamp) { Card("Swamp", owner: p1).tap { p1.library.add(_1) } }
  let!(:mountain) { Card("Mountain", owner: p1).tap { p1.library.add(_1) } }

  def fetch!
    p1.activate_ability(ability: delta.activated_abilities.first)
    game.stack.resolve!
  end

  it "costs 1 life and sacrifices itself" do
    expect { fetch! }.to change { p1.life }.by(-1)

    expect(p1.graveyard.cards.map(&:name)).to include("Polluted Delta")
  end

  it "offers only Island and Swamp cards" do
    fetch!

    choices = game.choices.last.choices
    expect(choices).to contain_exactly(island, swamp)
    expect(choices).not_to include(mountain)
  end

  it "puts the chosen land onto the battlefield untapped" do
    fetch!
    game.resolve_choice!(targets: [swamp])

    land = p1.permanents.by_name("Swamp").first
    expect(land).not_to be_nil
    expect(land).not_to be_tapped
  end
end
