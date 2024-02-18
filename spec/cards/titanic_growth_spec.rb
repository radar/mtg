require 'spec_helper'

RSpec.describe Magic::Cards::TitanicGrowth do
  include_context "two player game"
  let!(:wood_elves) { ResolvePermanent("Wood Elves") }

  it "gets +4/+4 until end of turn" do
    p1.add_mana(green: 2)
    p1.cast(card: Card("Titanic Growth")) do
      _1.auto_pay_mana
      _1.targeting(wood_elves)
    end

    game.tick!

    expect(wood_elves.power).to eq(5)
    expect(wood_elves.toughness).to eq(5)
  end
end
