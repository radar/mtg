# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KliTheResourceful do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:kili) { ResolvePermanent("Kíli The Resourceful", owner: p1) }

  it "is a 1/2 legendary Dwarf Scout" do
    expect(kili.power).to eq(1)
    expect(kili.toughness).to eq(2)
    expect(kili.type?("Dwarf")).to eq(true)
  end

  describe "card draw" do
    it "draws a card when another Dwarf enters, once each turn" do
      expect { ResolvePermanent("Iron Hills Stalwart", owner: p1) }.to change { p1.hand.count }.by(1)
      expect { ResolvePermanent("Iron Hills Blacksmith", owner: p1) }.not_to change { p1.hand.count }
    end

    it "draws a card when an Equipment enters" do
      expect { ResolvePermanent("Short Sword", owner: p1) }.to change { p1.hand.count }.by(1)
    end

    it "does not draw for an opponent's Dwarf or a non-Dwarf" do
      expect { ResolvePermanent("Iron Hills Stalwart", owner: p2) }.not_to change { p1.hand.count }
      expect { ResolvePermanent("Large Bear", owner: p1) }.not_to change { p1.hand.count }
    end
  end

  describe "free equip with an enduring story" do
    let!(:sword) { ResolvePermanent("Short Sword", owner: p1) }
    let!(:sword2) { ResolvePermanent("Short Sword", owner: p1) }
    let!(:bear) { ResolvePermanent("Large Bear", owner: p1) }

    def equip(equipment, mana)
      p1.activate_ability(ability: equipment.activated_abilities.first) do |a|
        a.targeting(bear)
        a.pay_mana(mana) unless mana.empty?
      end
      game.stack.resolve!
    end

    it "makes the first equip each turn free once you control three artifacts or legendaries" do
      equip(sword, {})
      expect(sword.attached_to).to eq(bear)
    end

    it "charges the equip cost for the second equip" do
      equip(sword, {})
      p1.add_mana(green: 1)
      equip(sword2, { generic: { green: 1 } })
      expect(sword2.attached_to).to eq(bear)
    end
  end
end
