# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WoodedFoothills do
  include_context "two player game"

  let!(:foothills) { ResolvePermanent("Wooded Foothills", owner: p1) }
  let!(:mountain) { Card("Mountain", owner: p1).tap { p1.library.add(_1) } }
  let!(:island) { Card("Island", owner: p1).tap { p1.library.add(_1) } }

  def fetch!
    p1.activate_ability(ability: foothills.activated_abilities.first)
    game.stack.resolve!
  end

  it "costs 1 life and sacrifices itself" do
    expect { fetch! }.to change { p1.life }.by(-1)

    expect(p1.graveyard.cards.map(&:name)).to include("Wooded Foothills")
  end

  it "offers only Mountain and Forest cards" do
    fetch!

    choices = game.choices.last.choices
    expect(choices.map(&:name).uniq).to contain_exactly("Mountain", "Forest")
    expect(choices).to include(mountain)
    expect(choices).not_to include(island)
  end

  it "puts the chosen land onto the battlefield untapped" do
    fetch!
    game.resolve_choice!(targets: [mountain])

    land = p1.permanents.by_name("Mountain").first
    expect(land).not_to be_nil
    expect(land).not_to be_tapped
  end

  it "can't be activated while tapped" do
    foothills.tap!
    expect { fetch! }.to raise_error(Magic::IllegalAction)
  end
end
