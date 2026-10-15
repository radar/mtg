# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EmeraldMedallion do
  include_context "two player game"

  let!(:medallion) { ResolvePermanent("Emerald Medallion", owner: p1) }

  before do
    go_to_main_phase!
    game.tick!
  end

  it "makes green spells you cast cost {1} less" do
    p1.add_mana(green: 1)
    p1.cast(card: Card("Grizzly Bears", owner: p1)) { |a| a.pay_mana(green: 1) }
    game.stack.resolve!

    expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
  end

  it "doesn't reduce non-green spells" do
    p1.add_mana(white: 1)

    expect { p1.cast(card: Card("Story Seeker", owner: p1)) { |a| a.pay_mana(white: 1) } }
      .to raise_error(Magic::Costs::Mana::CannotPay)
  end
end
