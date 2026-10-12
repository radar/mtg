# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NeedlevergePathway do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:pathway) { Card("Needleverge Pathway", owner: p1) }

  before do
    p1.hand.items.clear
    p1.hand.add(pathway)
  end

  it "is a double-faced card with a Pillarverge Pathway back face" do
    expect(pathway).to be_double_faced
    expect(pathway.back_face.name).to eq("Pillarverge Pathway")
  end

  it "is played as Needleverge Pathway by default, tapping for {R}" do
    p1.play_land(land: pathway)
    land = p1.permanents.by_name("Needleverge Pathway").first

    expect(land).not_to be_nil
    p1.activate_ability(ability: land.activated_abilities.first)
    expect(p1.mana_pool[:red]).to eq(1)
  end

  it "is played as Pillarverge Pathway with face: :back, tapping for {W}" do
    p1.play_land(land: pathway, face: :back)
    land = p1.permanents.by_name("Pillarverge Pathway").first

    expect(land).not_to be_nil
    expect(land.name).to eq("Pillarverge Pathway")
    p1.activate_ability(ability: land.activated_abilities.first)
    expect(p1.mana_pool[:white]).to eq(1)
    expect(p1.mana_pool[:red]).to eq(0)
  end

  it "ignores face: :back for a card with no back face" do
    forest = Card("Forest", owner: p1)
    p1.hand.add(forest)

    expect { p1.play_land(land: forest, face: :back) }.not_to raise_error
    expect(p1.permanents.by_name("Forest").count).to eq(1)
  end
end
