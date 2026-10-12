# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PatchworkBeastie do
  include_context "two player game"

  let!(:beastie) { ResolvePermanent("Patchwork Beastie", owner: p1) }

  def fill_graveyard_with_types(*names)
    names.each { |name| p1.graveyard.add(Card(name, owner: p1)) }
  end

  it "is a 3/3 Artifact Creature — Beast" do
    expect([beastie.power, beastie.toughness]).to eq([3, 3])
    expect(beastie.type?("Artifact")).to be true
    expect(beastie.type?("Beast")).to be true
  end

  it "can't attack or block without delirium" do
    fill_graveyard_with_types("Grizzly Bears", "Island", "Lightning Bolt")

    expect(beastie.can_attack?).to be false
    expect(beastie.can_block?(nil)).to be false
  end

  it "can attack and block with delirium" do
    fill_graveyard_with_types("Grizzly Bears", "Island", "Lightning Bolt", "Rampant Growth")

    expect(beastie.can_attack?).to be true
    expect(beastie.can_block?(nil)).to be true
  end

  context "at the beginning of your upkeep" do
    def upkeep!
      current_turn.untap!
      current_turn.upkeep!
    end

    it "mills a card when you accept" do
      expect { upkeep!; game.resolve_choice! }.to change { p1.graveyard.count }.by(1)
    end

    it "mills nothing when you decline" do
      expect { upkeep!; game.skip_choice! }.not_to change { p1.graveyard.count }
    end
  end
end
