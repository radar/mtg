# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EyeblightMassacre do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }
  let!(:grizzly_bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:opponent_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:opponent_elves) { ResolvePermanent("Wood Elves", owner: p2) }
  subject(:massacre) { Card("Eyeblight Massacre", owner: p1) }

  it "gives non-Elf creatures -2/-2 until end of turn" do
    p1.add_mana(black: 4)
    p1.cast(card: massacre) do
      _1.pay_mana(generic: { black: 2 }, black: 2)
    end
    game.stack.resolve!
    game.tick!

    aggregate_failures do
      expect(wood_elves.power).to eq(1)
      expect(wood_elves.toughness).to eq(1)
      expect(opponent_elves.power).to eq(1)
      expect(opponent_elves.toughness).to eq(1)

      expect(grizzly_bears.power).to eq(0)
      expect(grizzly_bears.toughness).to eq(0)
      expect(opponent_bears.power).to eq(0)
      expect(opponent_bears.toughness).to eq(0)
    end
  end
end
