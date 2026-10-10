# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GhostVacuum do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:vacuum) { ResolvePermanent("Ghost Vacuum", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p2) }
  let(:forest) { Card("Forest", owner: p2) }

  def exile!(card)
    vacuum.untap!
    p2.graveyard.add(card)
    p1.activate_ability(ability: vacuum.activated_abilities.first) { |a| a.targeting(card) }
    game.stack.resolve!
    game.settle!
  end

  it "exiles target card from a graveyard" do
    exile!(bears)

    expect(bears.zone).to be_exile
    expect(vacuum).to be_tapped
  end

  it "puts each exiled creature card onto the battlefield as a 1/1 flying Spirit" do
    exile!(bears)
    exile!(forest)
    vacuum.untap!
    p1.add_mana(colorless: 6)

    p1.activate_ability(ability: vacuum.activated_abilities.last) { |a| a.pay_mana(generic: { colorless: 6 }) }
    game.stack.resolve!
    game.settle!

    spirit = p1.creatures.find { _1.name == "Grizzly Bears" }
    expect(spirit).not_to be_nil
    expect([spirit.power, spirit.toughness]).to eq([1, 1])
    expect(spirit.type?("Spirit")).to be(true)
    expect(spirit.type?("Bear")).to be(true)
    expect(spirit.flying?).to be(true)
    expect(p1.lands).to be_empty
    expect(forest.zone).to be_exile
    expect(vacuum.zone).to be_nil.or(be_graveyard)
  end
end
