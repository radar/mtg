# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WirewoodSymbiote do
  include_context "two player game"

  let!(:symbiote) { ResolvePermanent("Wirewood Symbiote", owner: p1) }
  let!(:elf) { ResolvePermanent("Llanowar Elves", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def ability = symbiote.activated_abilities.first

  def activate(target, with: elf)
    p1.activate_ability(ability: ability) do
      _1.targeting(target)
      _1.pay_return_creature(with)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a 1/1 Insect" do
    expect([symbiote.power, symbiote.toughness]).to eq([1, 1])
    expect(symbiote.type?("Insect")).to eq(true)
  end

  it "returns an Elf you control to hand as a cost and untaps target creature" do
    bears.tap!
    activate(bears)
    expect(bears).to be_untapped
    expect(p1.hand.cards.map(&:name)).to include("Llanowar Elves")
    expect(game.battlefield.map(&:name)).not_to include("Llanowar Elves")
  end

  it "can untap an opponent's creature" do
    bears.tap!
    activate(bears)
    expect(bears).to be_untapped
  end

  it "cannot be activated without an Elf" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    expect {
      p1.activate_ability(ability: ability) do
        _1.targeting(bears)
        _1.pay_return_creature(other)
      end
    }.to raise_error(RuntimeError, /Return one of/)
  end

  it "cannot return an opponent's Elf" do
    theirs = ResolvePermanent("Llanowar Elves", owner: p2)
    expect {
      p1.activate_ability(ability: ability) do
        _1.targeting(bears)
        _1.pay_return_creature(theirs)
      end
    }.to raise_error(RuntimeError, /Return one of/)
  end

  it "can be activated only once each turn" do
    second = ResolvePermanent("Llanowar Elves", owner: p1)
    activate(bears)
    expect {
      p1.activate_ability(ability: ability) do
        _1.targeting(bears)
        _1.pay_return_creature(second)
      end
    }.to raise_error(Magic::IllegalAction, /once each turn/)
  end
end
