# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WindsweptHeath do
  include_context "two player game"

  let!(:heath) { ResolvePermanent("Windswept Heath", owner: p1) }
  let!(:forest) { Card("Forest", owner: p1).tap { p1.library.add(_1) } }
  let!(:plains) { Card("Plains", owner: p1).tap { p1.library.add(_1) } }
  let!(:island) { Card("Island", owner: p1).tap { p1.library.add(_1) } }

  def fetch!
    p1.activate_ability(ability: heath.activated_abilities.first)
    game.stack.resolve!
  end

  it "costs 1 life and sacrifices itself" do
    expect { fetch! }.to change { p1.life }.by(-1)

    expect(p1.graveyard.cards.map(&:name)).to include("Windswept Heath")
  end

  it "offers only Forest and Plains cards" do
    fetch!

    names = game.choices.last.choices.map(&:name).uniq
    expect(names).to contain_exactly("Forest", "Plains")
    expect(game.choices.last.choices).to include(forest, plains)
    expect(game.choices.last.choices).not_to include(island)
  end

  it "puts the chosen land onto the battlefield untapped" do
    fetch!
    game.resolve_choice!(targets: [plains])

    land = p1.permanents.by_name("Plains").first
    expect(land).not_to be_nil
    expect(land).not_to be_tapped
    expect(p1.library).not_to include(plains)
  end

  it "can't be activated while tapped" do
    heath.tap!
    expect { fetch! }.to raise_error(Magic::IllegalAction)
  end
end
