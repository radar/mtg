# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PopularEgotist do
  include_context "two player game"

  let!(:egotist) { ResolvePermanent("Popular Egotist", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def activate!(sacrificing)
    p1.add_mana(black: 2)
    p1.activate_ability(ability: egotist.activated_abilities.first) do
      _1.pay_mana(generic: { black: 1 }, black: 1)
      _1.pay_sacrifice(sacrificing)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a 3/2 Human Rogue" do
    expect([egotist.power, egotist.toughness]).to eq([3, 2])
  end

  it "sacrifices another creature to gain indestructible and tap itself" do
    activate!(bears)

    expect(bears.card.zone).to be_graveyard
    expect(egotist).to be_indestructible
    expect(egotist).to be_tapped
  end

  it "drains an opponent whenever you sacrifice a permanent" do
    activate!(bears)

    expect(p2.life).to eq(19)
    expect(p1.life).to eq(21)
  end

  it "doesn't trigger on an opponent's sacrifice" do
    other = ResolvePermanent("Grizzly Bears", owner: p2)
    other.sacrifice!
    game.settle!

    expect(p2.life).to eq(20)
    expect(p1.life).to eq(20)
  end
end
