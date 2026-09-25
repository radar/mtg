require "spec_helper"

RSpec.describe Magic::Cards::DoublingSeason do
  include_context "two player game"

  context "with one doubling season on the field" do
    let!(:doubling_season) { ResolvePermanent("Doubling Season", owner: p1) }
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

    it "creates two tokens" do
      p1.add_mana(white: 2)
      p1.cast(card: Card("Angelic Ascension")) do
        _1.targeting(wood_elves)
        _1.auto_pay_mana
      end

      game.stack.resolve!

      angels = game.battlefield.controlled_by(p1).creatures.by_name("Angel")
      expect(angels.count).to eq(2)
    end

    it "doubles counters" do
      wood_elves.trigger_effect(:add_counter, counter_type: Magic::Counters::Plus1Plus1, target: wood_elves)

      expect(wood_elves.counters.count).to eq(2)
    end
  end

  context "with two doubling seasons on the field" do
    let!(:doubling_season_1) { ResolvePermanent("Doubling Season", owner: p1) }
    let!(:doubling_season_2) { ResolvePermanent("Doubling Season", owner: p1) }
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

    it "creates four tokens" do
      p1.add_mana(white: 2)
      p1.cast(card: Card("Angelic Ascension")) do
        _1.targeting(wood_elves)
        _1.auto_pay_mana
      end

      game.stack.resolve!

      angels = game.battlefield.controlled_by(p1).creatures.by_name("Angel")
      expect(angels.count).to eq(4)
    end

    it "adds four counters" do
      wood_elves.trigger_effect(:add_counter, counter_type: Magic::Counters::Plus1Plus1, target: wood_elves)

      expect(wood_elves.counters.count).to eq(4)
    end
  end

  context "when other player controls doubling season" do
    let!(:doubling_season) { ResolvePermanent("Doubling Season", owner: p2) }
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

    it "does not double tokens" do
      p1.add_mana(white: 2)
      p1.cast(card: Card("Angelic Ascension")) do
        _1.targeting(wood_elves)
        _1.auto_pay_mana
      end

      game.stack.resolve!

      angels = game.battlefield.controlled_by(p1).creatures.by_name("Angel")
      expect(angels.count).to eq(1)
    end

    it "does not double counters" do
      wood_elves.trigger_effect(:add_counter, counter_type: Magic::Counters::Plus1Plus1, target: wood_elves)

      expect(wood_elves.counters.count).to eq(1)
    end
  end

  context "when the original effect specifies token state" do
    let!(:doubling_season) { ResolvePermanent("Doubling Season", owner: p1) }
    let!(:falconer_adept) { ResolvePermanent("Falconer Adept", owner: p1) }

    it "creates the additional tokens tapped too" do
      falconer_adept.trigger_effect(:create_token, token_class: Magic::Cards::FalconerAdept::BirdToken, enters_tapped: true)

      birds = game.battlefield.controlled_by(p1).creatures.by_name("Bird")
      expect(birds.count).to eq(2)
      expect(birds).to all(be_tapped)
    end

    it "creates the additional tokens tapped and attacking" do
      skip_to_combat!
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: falconer_adept, target: p2)
      current_turn.attackers_declared!

      birds = game.battlefield.controlled_by(p1).creatures.by_name("Bird")
      expect(birds.count).to eq(2)
      birds.each do |bird|
        expect(bird).to be_tapped
        expect(current_turn.attacks.map(&:attacker)).to include(bird)
      end
    end
  end
end
