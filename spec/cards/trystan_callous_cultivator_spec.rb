# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TrystanCallousCultivator do
  include_context "two player game"

  before do
    go_to_main_phase!
    8.times { p1.library.add(Card("Forest")) }
  end

  let(:trystan) { ResolvePermanent("Trystan, Callous Cultivator", owner: p1) }

  def first_main_phase!
    game.notify!(Magic::Events::FirstMainPhase.new(active_player: p1))
    game.settle!
  end

  it "is a 3/4 deathtouch Elf Druid with a back face" do
    expect([trystan.power, trystan.toughness]).to eq([3, 4])
    expect(trystan).to be_deathtouch
    expect(trystan.card).to be_double_faced
    expect(trystan.transformed?).to be(false)
  end

  describe "entering" do
    it "mills three cards" do
      expect { trystan }.to change { p1.library.count }.by(-3)
      expect(p1.graveyard.cards.size).to eq(3)
    end

    it "gains no life when no Elf card is in the graveyard" do
      expect { trystan }.not_to change { p1.life }
    end

    it "gains 2 life when an Elf card is in the graveyard" do
      p1.graveyard.add(Card("Skyway Sniper", owner: p1))

      expect { trystan }.to change { p1.life }.by(2)
    end
  end

  describe "at the beginning of your first main phase" do
    before { trystan }

    it "offers to pay {B}" do
      p1.add_mana(black: 1)
      first_main_phase!

      expect(game.choices.last).to be_a(Magic::Choice::PayToTransform)
    end

    it "is not offered without {B} available" do
      first_main_phase!

      expect(game.choices).to be_empty
    end

    it "transforms into Trystan, Penitent Culler when paid" do
      p1.add_mana(black: 1)
      first_main_phase!
      game.resolve_choice!(payment: nil)
      game.tick!

      expect(trystan.transformed?).to be(true)
      expect(trystan.name).to eq("Trystan, Penitent Culler")
      expect(trystan.mana_value).to eq(3)
      expect(trystan.colors).to eq([:black])
      expect(p1.mana_pool[:black]).to eq(0)
    end

    it "stays as it is when declined" do
      p1.add_mana(black: 1)
      first_main_phase!
      game.skip_choice!

      expect(trystan.transformed?).to be(false)
      expect(p1.mana_pool[:black]).to eq(1)
    end

    it "does nothing on the opponent's first main phase" do
      p1.add_mana(black: 1)
      game.notify!(Magic::Events::FirstMainPhase.new(active_player: p2))
      game.settle!

      expect(game.choices).to be_empty
    end
  end

  it "goes to the graveyard as the front face" do
    trystan.transform!
    trystan.destroy!
    game.settle!

    expect(p1.graveyard.cards.map(&:name)).to include("Trystan, Callous Cultivator")
  end

  describe "transformed" do
    before do
      trystan
      trystan.transform!
      game.settle!
    end

    it "mills three cards on transforming, then may exile an Elf card to drain each opponent for 2" do
      expect(p1.graveyard.cards.size).to eq(6) # three from entering, three from transforming
      expect(game.choices).to be_empty # no Elf card milled
    end

    it "drains when an Elf card is exiled" do
      elf = Card("Skyway Sniper", owner: p1)
      p1.graveyard.add(elf)
      trystan.transform!
      trystan.transform!
      game.settle!

      game.resolve_choice!(target: elf)

      expect(elf.zone).to be_exile
      expect(p2.life).to eq(18)
    end

    it "may decline to exile" do
      p1.graveyard.add(Card("Skyway Sniper", owner: p1))
      trystan.transform!
      trystan.transform!
      game.settle!
      game.skip_choice!

      expect(p2.life).to eq(20)
    end

    it "transforms back for {G}" do
      p1.add_mana(green: 1)
      first_main_phase!
      game.resolve_choice!(payment: nil)

      expect(trystan.transformed?).to be(false)
      expect(trystan.name).to eq("Trystan, Callous Cultivator")
    end
  end
end
