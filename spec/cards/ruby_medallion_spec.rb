# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RubyMedallion do
  include_context "two player game"

  let!(:medallion) { ResolvePermanent("Ruby Medallion", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    go_to_main_phase!
    game.tick!
  end

  it "makes red spells you cast cost {1} less" do
    p1.add_mana(red: 1)
    p1.cast(card: Card("Sure Strike", owner: p1)) { |a| a.pay_mana(red: 1).targeting(bears) }
    game.stack.resolve!
    game.tick!

    expect(bears.power).to eq(5)
  end

  it "doesn't reduce red spells an opponent casts" do
    p2.add_mana(red: 1)

    expect { p2.cast(card: Card("Sure Strike", owner: p2)) { |a| a.pay_mana(red: 1).targeting(bears) } }
      .to raise_error(Magic::Costs::Mana::CannotPay)
  end

  it "doesn't reduce non-red spells" do
    p1.add_mana(green: 1)

    expect { p1.cast(card: Card("Grizzly Bears", owner: p1)) { |a| a.pay_mana(green: 1) } }
      .to raise_error(Magic::Costs::Mana::CannotPay)
  end
end
