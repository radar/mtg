# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LeylineOfTransformation do
  include_context "two player game"

  def p1_library = [Card("Leyline Of Transformation", owner: p1), *13.times.map { Card("Forest", owner: p1) }]

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before do
    game.resolve_choice!
    game.settle!
    game.resolve_choice!(creature_type: "Elf")
    game.tick!
  end

  it "asks for a creature type as it enters" do
    expect(p1.permanents.find { _1.name == "Leyline of Transformation" }.chosen_creature_type).to eq("Elf")
  end

  it "makes creatures you control the chosen type in addition to their other types" do
    expect(bears.type?("Elf")).to be(true)
    expect(bears.type?("Bear")).to be(true)
  end

  it "doesn't change your opponent's creatures" do
    expect(theirs.type?("Elf")).to be(false)
  end

  it "applies to creature cards you own that aren't on the battlefield" do
    in_hand = Card("Grizzly Bears", owner: p1).tap { p1.hand.add(_1) }
    in_graveyard = Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) }

    expect(in_hand.types).to include("Elf")
    expect(in_graveyard.types).to include("Elf")
  end

  it "applies to creature spells you control" do
    spell = Card("Grizzly Bears", owner: p1).tap { p1.hand.add(_1) }
    go_to_main_phase!
    p1.add_mana(green: 2)
    p1.cast(card: spell) { _1.pay_mana(generic: { green: 1 }, green: 1) }

    expect(spell.types).to include("Elf")
  end

  it "doesn't apply to an opponent's cards or to noncreature cards" do
    expect(Card("Grizzly Bears", owner: p2).types).not_to include("Elf")
    expect(Card("Lightning Bolt", owner: p1).types).not_to include("Elf")
  end

  it "supplies lord effects for the chosen type (an Elf is an Elf for Elvish Archdruid-style checks)" do
    expect(p1.creatures.by_type("Elf")).to include(bears)
  end
end
