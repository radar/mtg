# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChthonianNightmare do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:nightmare) { ResolvePermanent("Chthonian Nightmare", owner: p1) }
  let!(:fodder) { ResolvePermanent("Colossal Dreadmaw", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p1) }

  before do
    game.settle!
    p1.graveyard.add(bears)
  end

  def reanimate(target, x:)
    p1.activate_ability(ability: nightmare.activated_abilities.first) do |a|
      a.targeting(target)
      a.pay_energy_x(x)
      a.pay_sacrifice(fodder)
      a.pay_self_return
    end
    game.stack.resolve!
    game.settle!
  end

  it "gives three energy when it enters" do
    expect(p1.energy).to eq(3)
  end

  it "pays X energy, sacrifices a creature, returns itself and reanimates a creature with mana value X" do
    reanimate(bears, x: 2)

    expect(p1.energy).to eq(1)
    expect(p1.creatures.map(&:name)).to eq(["Grizzly Bears"])
    expect(p1.graveyard.cards).to include(fodder.card)
    expect(p1.hand.cards).to include(nightmare.card)
    expect(p1.enchantments).to be_empty
  end

  it "does nothing when the target's mana value is not X" do
    reanimate(bears, x: 1)

    expect(p1.creatures).to be_empty
    expect(p1.graveyard.cards).to include(bears)
  end

  it "cannot pay more energy than the player has" do
    expect { reanimate(bears, x: 4) }.to raise_error(Magic::IllegalAction)
  end
end
