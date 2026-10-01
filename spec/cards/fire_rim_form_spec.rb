# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FireRimForm do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let(:form) { Card("Fire-Rim Form", owner: p1) }

  before do
    p1.hand.add(form)
    p1.add_mana(red: 2)
    p1.cast(card: form) { |a| a.pay_mana(red: 1, generic: { red: 1 }).targeting(bears) }
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  it "has flash" do
    expect(form.has_keyword?(Magic::Cards::Keywords::FLASH)).to eq(true)
  end

  it "attaches to the creature, giving it +2/+0" do
    expect(bears.attachments.map(&:name)).to eq(["Fire-Rim Form"])
    expect([bears.power, bears.toughness]).to eq([4, 2])
  end

  it "gives first strike until end of turn" do
    expect(bears.has_keyword?(Magic::Cards::Keywords::FIRST_STRIKE)).to eq(true)

    current_turn.end!
    current_turn.cleanup!
    game.tick!
    expect(bears.has_keyword?(Magic::Cards::Keywords::FIRST_STRIKE)).to eq(false)
    expect(bears.power).to eq(4)
  end
end
