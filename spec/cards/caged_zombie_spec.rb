# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CagedZombie do
  include_context "two player game"

  let!(:zombie) { ResolvePermanent("Caged Zombie", owner: p1) }

  def activate
    p1.add_mana(black: 2)
    p1.activate_ability(ability: zombie.activated_abilities.first) { _1.pay_mana(generic: { black: 1 }, black: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 2/3 Zombie" do
    expect([zombie.power, zombie.toughness]).to eq([2, 3])
  end

  it "makes each opponent lose 2 life if a creature died this turn" do
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!
    activate

    expect(p2.life).to eq(18)
    expect(zombie).to be_tapped
  end

  it "can't be activated if no creature died this turn" do
    expect { activate }.to raise_error(StandardError)
  end
end
