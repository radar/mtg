# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BurdenedStoneback do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:stoneback) { ResolvePermanent("Burdened Stoneback", owner: p1) }

  it "is a 4/4 giant warrior that enters with two -1/-1 counters" do
    expect(stoneback.card.types).to include("Giant", "Warrior")
    expect(stoneback.power).to eq(2)
    expect(stoneback.toughness).to eq(2)
    expect(stoneback.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(2)
  end

  it "gives target creature indestructible until end of turn for {1}{W}, remove a counter, as a sorcery" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(white: 2)

    p1.activate_ability(ability: stoneback.activated_abilities.first) { |a| a.pay_mana(generic: { white: 1 }, white: 1).targeting(bears) }
    game.stack.resolve!

    expect(bears).to have_keyword(:indestructible)
    expect(stoneback.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
  end

  it "can only be activated as a sorcery" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(white: 2)
    current_turn.beginning_of_combat!

    expect { p1.activate_ability(ability: stoneback.activated_abilities.first) { |a| a.pay_mana(generic: { white: 1 }, white: 1).targeting(bears) } }
      .to raise_error(Magic::IllegalAction)
  end
end
