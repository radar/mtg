# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HauntedScreen do
  include_context "two player game"

  let!(:screen) { ResolvePermanent("Haunted Screen", owner: p1) }

  it "taps for white or black mana" do
    p1.activate_ability(ability: screen.activated_abilities.first) { _1.choose(:black) }

    expect(p1.mana_pool[:black]).to eq(1)
  end

  it "taps for green, blue or red mana by paying 1 life" do
    p1.activate_ability(ability: screen.activated_abilities[1]) { _1.choose(:blue) }

    expect(p1.mana_pool[:blue]).to eq(1)
    expect(p1.life).to eq(19)
  end

  it "becomes a 7/7 Spirit creature once" do
    p1.add_mana(colorless: 7)
    p1.activate_ability(ability: screen.activated_abilities.last) { |a| a.pay_mana(generic: { colorless: 7 }) }
    game.stack.resolve!
    game.tick!

    expect(screen).to be_creature
    expect(screen.power).to eq(7)
    expect(screen.toughness).to eq(7)
    expect(screen.type?("Spirit")).to be(true)
    expect(screen.type?("Artifact")).to be(true)

    p1.add_mana(colorless: 7)
    expect do
      p1.activate_ability(ability: screen.activated_abilities.last) { |a| a.pay_mana(generic: { colorless: 7 }) }
    end.to raise_error(Magic::IllegalAction)
  end
end
