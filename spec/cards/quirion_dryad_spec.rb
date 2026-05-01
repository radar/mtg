# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::QuirionDryad do
  include_context "two player game"

  subject!(:quirion_dryad) { ResolvePermanent("Quirion Dryad") }

  it "starts as a 1/1" do
    expect(quirion_dryad.power).to eq(1)
    expect(quirion_dryad.toughness).to eq(1)
  end

  context "when you cast a white spell" do
    it "puts a +1/+1 counter on Quirion Dryad" do
      p1.add_mana(white: 2)
      p1.cast(card: Card("Alpine Watchdog", owner: p1)) do
        _1.pay_mana(white: 1, generic: { white: 1 })
      end

      game.stack.resolve!
      game.tick!

      expect(quirion_dryad.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
      expect(quirion_dryad.power).to eq(2)
      expect(quirion_dryad.toughness).to eq(2)
    end
  end

  context "when you cast a blue spell" do
    it "puts a +1/+1 counter on Quirion Dryad" do
      p1.add_mana(blue: 1)
      p1.cast(card: Card("Aegis Turtle", owner: p1)) do
        _1.pay_mana(blue: 1)
      end

      game.stack.resolve!

      expect(quirion_dryad.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
    end
  end

  context "when you cast a black spell" do
    it "puts a +1/+1 counter on Quirion Dryad" do
      p1.add_mana(black: 5)
      p1.cast(card: Card("Blood Glutton", owner: p1)) do
        _1.pay_mana(black: 1, generic: { black: 4 })
      end

      game.stack.resolve!

      expect(quirion_dryad.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
    end
  end

  context "when you cast a red spell" do
    it "puts a +1/+1 counter on Quirion Dryad" do
      p1.add_mana(red: 1)
      p1.cast(card: Card("Shock", owner: p1)) do
        _1.targeting(p2)
        _1.pay_mana(red: 1)
      end

      game.stack.resolve!

      expect(quirion_dryad.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
    end
  end

  context "when you cast a green spell" do
    it "does not put a +1/+1 counter on Quirion Dryad" do
      p1.add_mana(green: 2)
      p1.cast(card: Card("Grizzly Bears", owner: p1)) do
        _1.pay_mana(green: 1, generic: { green: 1 })
      end

      game.stack.resolve!

      expect(quirion_dryad.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(0)
      expect(quirion_dryad.power).to eq(1)
      expect(quirion_dryad.toughness).to eq(1)
    end
  end

  context "when you cast a colorless spell" do
    it "does not put a +1/+1 counter on Quirion Dryad" do
      p1.add_mana(green: 2)
      p1.cast(card: Card("Alpha Myr", owner: p1)) do
        _1.pay_mana(generic: { green: 2 })
      end

      game.stack.resolve!

      expect(quirion_dryad.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(0)
    end
  end

  context "when an opponent casts a white spell" do
    it "does not put a +1/+1 counter on Quirion Dryad" do
      watchdog = Card("Alpine Watchdog", owner: p2)
      p2.hand.add(watchdog)
      p2.add_mana(white: 2)
      p2.cast(card: watchdog) do
        _1.pay_mana(white: 1, generic: { white: 1 })
      end

      game.stack.resolve!

      expect(quirion_dryad.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(0)
    end
  end

  context "when an opponent casts a red spell" do
    it "does not put a +1/+1 counter on Quirion Dryad" do
      shock = Card("Shock", owner: p2)
      p2.hand.add(shock)
      p2.add_mana(red: 1)
      p2.cast(card: shock) do
        _1.targeting(p1)
        _1.pay_mana(red: 1)
      end

      game.stack.resolve!

      expect(quirion_dryad.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(0)
    end
  end
end
