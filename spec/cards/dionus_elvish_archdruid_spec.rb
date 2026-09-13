# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DionusElvishArchdruid do
  include_context "two player game"

  let!(:dionus) { ResolvePermanent("Dionus, Elvish Archdruid", owner: p1) }

  it "is a 3/3 legendary Elf Druid" do
    expect(dionus.power).to eq(3)
    expect(dionus.toughness).to eq(3)
    expect(dionus).to be_legendary
    expect(dionus.type?("Elf")).to be true
    expect(dionus.type?("Druid")).to be true
  end

  context "when an Elf you control becomes tapped during your turn" do
    let!(:llanowar_elves) { ResolvePermanent("Llanowar Elves", owner: p1) }

    it "untaps it and puts a +1/+1 counter on it" do
      ability = llanowar_elves.activated_abilities.first
      p1.activate_ability(ability: ability)
      game.tick!

      expect(llanowar_elves.tapped?).to be false
      expect(llanowar_elves.power).to eq(2)
      expect(llanowar_elves.toughness).to eq(2)
    end

    it "triggers only once each turn" do
      ability = llanowar_elves.activated_abilities.first
      p1.activate_ability(ability: ability)
      game.tick!
      p1.activate_ability(ability: ability)
      game.tick!

      expect(llanowar_elves.power).to eq(2)
      expect(llanowar_elves.toughness).to eq(2)
    end

    it "applies to Dionus itself, since it is an Elf" do
      action = Magic::Actions::TapPermanent.new(game: game, player: p1, permanent: dionus)
      game.take_action(action)
      game.tick!

      expect(dionus.tapped?).to be false
      expect(dionus.power).to eq(4)
      expect(dionus.toughness).to eq(4)
    end
  end

  context "when a non-Elf creature you control becomes tapped" do
    let!(:grizzly_bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "does not untap it or add a counter" do
      action = Magic::Actions::TapPermanent.new(game: game, player: p1, permanent: grizzly_bears)
      game.take_action(action)
      game.tick!

      expect(grizzly_bears.tapped?).to be true
      expect(grizzly_bears.power).to eq(2)
      expect(grizzly_bears.toughness).to eq(2)
    end
  end

  context "when an Elf an opponent controls becomes tapped" do
    let!(:opponent_elves) { ResolvePermanent("Llanowar Elves", owner: p2) }

    it "does not untap it or add a counter" do
      action = Magic::Actions::TapPermanent.new(game: game, player: p2, permanent: opponent_elves)
      game.take_action(action)
      game.tick!

      expect(opponent_elves.tapped?).to be true
      expect(opponent_elves.power).to eq(1)
      expect(opponent_elves.toughness).to eq(1)
    end
  end

  context "when it is not your turn" do
    let!(:llanowar_elves) { ResolvePermanent("Llanowar Elves", owner: p1) }

    it "does not untap your Elf or add a counter" do
      game.next_turn

      action = Magic::Actions::TapPermanent.new(game: game, player: p1, permanent: llanowar_elves)
      game.take_action(action)
      game.tick!

      expect(llanowar_elves.tapped?).to be true
      expect(llanowar_elves.power).to eq(1)
      expect(llanowar_elves.toughness).to eq(1)
    end
  end
end
