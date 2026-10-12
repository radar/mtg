# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ValgavothsFaithful do
  include_context "two player game"

  let!(:faithful) { ResolvePermanent("Valgavoth's Faithful", owner: p1) }
  let!(:bears) { Card("Grizzly Bears") }

  before do
    go_to_main_phase!
    p1.graveyard.add(bears)
  end

  def activate
    p1.add_mana(black: 4)
    p1.activate_ability(ability: faithful.activated_abilities.first) do
      _1.pay_mana(generic: { black: 3 }, black: 1).targeting(bears)
    end
    game.stack.resolve!
    game.tick!
  end

  it "is a 1/1 Human Cleric" do
    expect([faithful.power, faithful.toughness]).to eq([1, 1])
  end

  it "sacrifices itself and returns a creature card from the graveyard" do
    activate

    expect(p1.graveyard.cards.map(&:name)).to include("Valgavoth's Faithful")
    expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
  end

  it "can't be activated outside of sorcery timing" do
    go_to_main_phase_for!(p2)
    p1.add_mana(black: 4)
    expect do
      p1.activate_ability(ability: faithful.activated_abilities.first) do
        _1.pay_mana(generic: { black: 3 }, black: 1).targeting(bears)
      end
    end.to raise_error(Magic::IllegalAction)
  end
end
