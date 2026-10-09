# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::IronHillsStalwart do
  include_context "two player game"

  it "is a 4/5 Dwarf with reach and trample" do
    stalwart = ResolvePermanent("Iron Hills Stalwart", owner: p1)
    expect(stalwart.power).to eq(4)
    expect(stalwart.type?("Dwarf")).to eq(true)
    expect(stalwart.keywords).to include(Magic::Cards::Keywords::REACH, Magic::Cards::Keywords::TRAMPLE)
  end

  context "with an Equipment and creatures in play" do
    let!(:sword) { ResolvePermanent("Short Sword", owner: p1) }
    let!(:bear) { ResolvePermanent("Large Bear", owner: p1) }
    let!(:other) { ResolvePermanent("Guardian Of The Halls", owner: p1) }

    before do
      game.skip_choice! while game.choices.any?
      ResolvePermanent("Iron Hills Stalwart", owner: p1)
    end

    it "attaches the Equipment to the chosen creature" do
      game.resolve_choice!(target: bear)
      game.tick!
      expect(sword.attached_to).to eq(bear)
      expect(bear.power).to eq(6)
    end

    it "may choose no creature" do
      game.skip_choice!
      expect(sword.attached_to).to be_nil
    end
  end

  it "does nothing without an Equipment" do
    ResolvePermanent("Iron Hills Stalwart", owner: p1)
    expect(game.choices).to be_empty
  end
end
