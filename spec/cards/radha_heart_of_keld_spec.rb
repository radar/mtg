# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RadhaHeartOfKeld do
  include_context "two player game"

  let(:radha) { ResolvePermanent("Radha, Heart Of Keld") }

  context "first strike" do
    context "during controller's turn" do
      it "has first strike" do
        expect(radha).to have_keyword(:first_strike)
      end
    end

    context "not during controller's turn" do
      before { game.next_turn }

      it "does not have first strike" do
        expect(radha).not_to have_keyword(:first_strike)
      end
    end
  end

  context "play lands from top of library" do
    before do
      p1.library.add(Card("Forest"))
    end

    it "can play a land from the top of the library" do
      top = p1.library.cards.first
      expect(top.name).to eq("Forest")
      p1.play_land(land: top)
      expect(game.battlefield.lands.controlled_by(p1).by_name("Forest")).not_to be_empty
    end
  end

  context "{4}{R}{G} pump ability" do
    before do
      p1.add_mana(red: 3, green: 3)
      2.times { ResolvePermanent("Forest", owner: p1) }
    end

    it "gives Radha +X/+X where X is lands controlled" do
      x = p1.lands.count
      p1.activate_ability(ability: radha.activated_abilities.first) do
        _1.pay_mana(red: 1, green: 1, generic: { red: 2, green: 2 })
      end
      game.stack.resolve!
      game.tick!

      expect(radha.power).to eq(3 + x)
      expect(radha.toughness).to eq(3 + x)
    end
  end
end
