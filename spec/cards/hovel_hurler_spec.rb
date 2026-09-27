# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HovelHurler do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:hurler) { ResolvePermanent("Hovel Hurler", owner: p1) }

  it "is a 6/7 giant warrior that enters with two -1/-1 counters" do
    expect(hurler.card.types).to include("Giant", "Warrior")
    expect(hurler.power).to eq(4)
    expect(hurler.toughness).to eq(5)
  end

  it "gives another target creature you control +1/+0 and flying for {R/W}{R/W}, remove a counter, as a sorcery" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(red: 2)

    p1.activate_ability(ability: hurler.activated_abilities.first) { |a| a.pay_mana(red: 2).targeting(bears) }
    game.stack.resolve!

    expect(bears.power).to eq(3)
    expect(bears.flying?).to be(true)
  end

  it "cannot target itself" do
    p1.add_mana(red: 2)

    expect { p1.activate_ability(ability: hurler.activated_abilities.first) { |a| a.pay_mana(red: 2).targeting(hurler) } }
      .to raise_error(/Invalid target/)
  end
end
