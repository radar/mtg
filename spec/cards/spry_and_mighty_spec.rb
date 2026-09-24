# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SpryAndMighty do
  include_context "two player game"

  before { go_to_main_phase! }

  def cast_spry_and_mighty
    p1.add_mana(green: 5)
    p1.cast(card: Card("Spry And Mighty")) { _1.auto_pay_mana }
    game.stack.resolve!
  end

  context "with two creatures" do
    let!(:elves) { ResolvePermanent("Wood Elves", owner: p1) }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:wretch) { ResolvePermanent("Retched Wretch", owner: p1) }

    it "draws X cards and gives both +X/+X and trample, X being the difference in power" do
      cast_spry_and_mighty
      expect { game.resolve_choice!(targets: [elves, wretch]) }.to change { p1.hand.count }.by(3)
      game.tick!

      expect([elves.power, elves.toughness]).to eq([4, 4])
      expect([wretch.power, wretch.toughness]).to eq([7, 5])
      expect(elves).to be_trample
      expect(wretch).to be_trample
      expect(bears).not_to be_trample
    end

    it "gives trample but draws nothing when the powers are equal" do
      other_bears = ResolvePermanent("Grizzly Bears", owner: p1)
      cast_spry_and_mighty
      expect { game.resolve_choice!(targets: [bears, other_bears]) }.not_to(change { p1.hand.count })
      game.tick!
      expect(bears.power).to eq(2)
      expect(bears).to be_trample
    end

    it "must choose exactly two creatures you control" do
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      cast_spry_and_mighty
      choice = game.choices.last
      expect { choice.resolve!(targets: [elves]) }.to raise_error(described_class::CreaturesChoice::InvalidChoice)
      expect { choice.resolve!(targets: [elves, theirs]) }.to raise_error(described_class::CreaturesChoice::InvalidChoice)
    end
  end

  it "does nothing with fewer than two creatures" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    cast_spry_and_mighty
    expect(game.choices).to be_empty
  end
end
