# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RiverguardsReflexes do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def cast_reflexes
    p1.add_mana(white: 2)
    p1.cast(card: Card("Riverguard's Reflexes")) do
      _1.auto_pay_mana
      _1.targeting(bears)
    end
    game.stack.resolve!
    game.tick!
  end

  it "gives the target +2/+2 and first strike until end of turn" do
    go_to_main_phase!
    cast_reflexes

    expect(bears.power).to eq(4)
    expect(bears.toughness).to eq(4)
    expect(bears).to be_first_strike

    current_turn.end!
    current_turn.cleanup!
    expect(bears.power).to eq(2)
    expect(bears).not_to be_first_strike
  end

  it "untaps the target" do
    bears.tap!
    cast_reflexes

    expect(bears).to be_untapped
  end
end
