# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ErkenbrandLordOfWestfold do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:enemy_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def settle
    game.settle!
    game.tick!
  end

  it "is a legendary 3/3 Human Soldier" do
    card = Card("Erkenbrand Lord Of Westfold")
    expect(card).to be_legendary
    expect([card.base_power, card.base_toughness]).to eq([3, 3])
    expect(card.type?("Human")).to be(true)
    expect(card.type?("Soldier")).to be(true)
  end

  it "triggers when Erkenbrand himself enters, giving your creatures +1/+0" do
    erkenbrand = ResolvePermanent("Erkenbrand Lord Of Westfold", owner: p1)
    settle

    expect(erkenbrand.power).to eq(4)
    expect(bears.power).to eq(3)
    expect(bears.toughness).to eq(2)
  end

  it "does not pump the opponent's creatures" do
    ResolvePermanent("Erkenbrand Lord Of Westfold", owner: p1)
    settle

    expect(enemy_bears.power).to eq(2)
  end

  it "triggers when another Human you control enters" do
    erkenbrand = ResolvePermanent("Erkenbrand Lord Of Westfold", owner: p1)
    settle
    expect(bears.power).to eq(3)

    # Protector of Gondor is a Human, and its Human Soldier token entering is a second trigger.
    ResolvePermanent("Protector Of Gondor", owner: p1)
    settle

    expect(bears.power).to eq(5)
    expect(erkenbrand.power).to eq(6)
  end

  it "does not trigger when a non-Human creature enters" do
    erkenbrand = ResolvePermanent("Erkenbrand Lord Of Westfold", owner: p1)
    settle
    ResolvePermanent("Grizzly Bears", owner: p1)
    settle

    expect(erkenbrand.power).to eq(4)
    expect(bears.power).to eq(3)
    expect(game.choices).to be_empty
  end

  it "does not trigger when an opponent's Human enters" do
    erkenbrand = ResolvePermanent("Erkenbrand Lord Of Westfold", owner: p1)
    settle
    ResolvePermanent("Protector Of Gondor", owner: p2)
    settle

    expect(erkenbrand.power).to eq(4)
    expect(bears.power).to eq(3)
  end

  it "only lasts until end of turn" do
    erkenbrand = ResolvePermanent("Erkenbrand Lord Of Westfold", owner: p1)
    settle
    expect(erkenbrand.power).to eq(4)

    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(erkenbrand.power).to eq(3)
    expect(bears.power).to eq(2)
  end
end
