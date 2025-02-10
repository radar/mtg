require 'spec_helper'

RSpec.describe Magic::Cards::DaxosBlessedByTheSun do
  include_context "two player game"

  let!(:daxos) { ResolvePermanent("Daxos, Blessed By The Sun") }

  context "power and toughness" do
    it "has 2 power and 2 toughness" do
      expect(daxos.power).to eq(2)
      expect(daxos.toughness).to eq(2)
    end
  end

  context "enters ability" do
    let(:elves) { Card("Llanowar Elves") }

    it "gains controller 1 life" do
      p1.add_mana(green: 1)
      p1.cast(card: elves) do
        _1.pay_mana(green: 1)
      end

      game.stack.resolve!
      game.tick!

      expect(p1.life).to eq(21)
    end
  end

  context "dies ability" do
    let(:elves) { ResolvePermanent("Llanowar Elves") }

    it "gains controller 1 life" do
      elves.sacrifice!

      expect(p1.life).to eq(22)
    end
  end
end
