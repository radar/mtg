require "spec_helper"

RSpec.describe Magic::Cards::ReadTheTides do
  include_context "two player game"

  let(:read_the_tides) { Card("Read The Tides") }

  it "chooses draw three cards" do
    expect(p1).to receive(:draw!).exactly(3).times

    mode_class = read_the_tides.modes.first

    p1.add_mana(blue: 6)
    p1.cast(card: read_the_tides) do
      _1.choose_mode(mode_class)
      _1.pay_mana(blue: 1, generic: { blue: 5 })
    end

    game.stack.resolve!
  end

  context "wood elves on the field" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

    it "chooses return a single target" do
      mode_class = read_the_tides.modes.last
      p1.add_mana(blue: 6)
      p1.cast(card: read_the_tides) do
        _1.choose_mode(mode_class) do |mode|
          mode.targeting(wood_elves)
        end
        _1.pay_mana(blue: 1, generic: { blue: 5 })
      end

      game.stack.resolve!
      expect(p2.hand.by_name("Wood Elves").count).to eq(1)
    end
  end
end
