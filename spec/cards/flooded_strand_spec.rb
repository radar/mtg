# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FloodedStrand do
  include_context "two player game"

  let!(:strand) { ResolvePermanent("Flooded Strand", owner: p1) }
  let!(:plains) { Card("Plains", owner: p1).tap { p1.library.add(_1) } }
  let!(:island) { Card("Island", owner: p1).tap { p1.library.add(_1) } }
  let!(:mountain) { Card("Mountain", owner: p1).tap { p1.library.add(_1) } }

  def fetch!
    p1.activate_ability(ability: strand.activated_abilities.first)
    game.stack.resolve!
  end

  it "costs 1 life and sacrifices itself" do
    expect { fetch! }.to change { p1.life }.by(-1)

    expect(p1.graveyard.cards.map(&:name)).to include("Flooded Strand")
  end

  it "offers only Plains and Island cards" do
    fetch!

    choices = game.choices.last.choices
    expect(choices).to contain_exactly(plains, island)
    expect(choices).not_to include(mountain)
  end

  it "puts the chosen land onto the battlefield untapped" do
    fetch!
    game.resolve_choice!(targets: [island])

    land = p1.permanents.by_name("Island").first
    expect(land).not_to be_nil
    expect(land).not_to be_tapped
  end

  it "can't be activated while tapped" do
    strand.tap!
    expect { fetch! }.to raise_error(Magic::IllegalAction)
  end
end
