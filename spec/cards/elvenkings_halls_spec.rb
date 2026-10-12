# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ElvenkingsHalls do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:land) { ResolvePermanent("Elvenking's Halls", owner: p1) }

  it "enters tapped" do
    expect(land.tapped?).to eq(true)
  end

  it "taps for green or blue" do
    land.untap!
    p1.activate_ability(ability: land.activated_abilities.first) { _1.choose(:blue) }
    expect(p1.mana_pool[:blue]).to eq(1)
  end

  it "sacrifices to put two +1/+1 counters on an Elf" do
    land.untap!
    elf = ResolvePermanent("Elvish Mystic", owner: p1)
    p1.add_mana(green: 2, blue: 2)
    p1.activate_ability(ability: land.activated_abilities.last) do
      _1.targeting(elf)
      _1.pay_mana(generic: { green: 1, blue: 1 }, green: 1, blue: 1)
    end
    game.stack.resolve!
    game.tick!

    expect(elf.power).to eq(3)
    expect(elf.toughness).to eq(3)
    expect(p1.graveyard.cards.map(&:name)).to include("Elvenking's Halls")
  end

  it "can't target a non-Elf" do
    land.untap!
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(green: 2, blue: 2)
    expect do
      p1.activate_ability(ability: land.activated_abilities.last) do
        _1.targeting(bears)
        _1.pay_mana(generic: { green: 1, blue: 1 }, green: 1, blue: 1)
      end
    end.to raise_error(StandardError)
  end
end
