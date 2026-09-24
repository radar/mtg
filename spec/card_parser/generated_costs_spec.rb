# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

RSpec.describe "CardParser generated costs in play" do
  include CardParserHelpers
  include_context "two player game"

  describe "hybrid mana" do
    before { go_to_main_phase! }

    it "generates a hybrid cost that either colour can pay" do
      source = generate("Parsed Twin {B/G}{B/G}\nCreature — Elf\n1/3\n")
      expect(source).to include("cost black_or_green: 2")
      load_card("Parsed Twin {B/G}{B/G}\nCreature — Elf\n1/3\n")

      [{ black: 2 }, { green: 2 }, { black: 1, green: 1 }].each do |mana|
        card = Card("Parsed Twin", owner: p1)
        p1.add_mana(mana)
        p1.cast(card:) { _1.pay_mana(mana) }
        game.stack.resolve!
      end
      expect(game.battlefield.creatures.by_name("Parsed Twin").count).to eq(3)
    end

    it "mixes hybrid with generic and coloured symbols" do
      expect(generate("Parsed Blend {1}{R/W}{G}\nCreature — Elf\n2/2\n")).to include("cost generic: 1, red_or_white: 1, green: 1")
    end

    it "can't be paid with an off-colour mana" do
      load_card("Parsed Twin {B/G}{B/G}\nCreature — Elf\n1/3\n")
      p1.add_mana(red: 2)
      expect { p1.cast(card: Card("Parsed Twin", owner: p1)) { _1.pay_mana(red: 2) } }.to raise_error(StandardError)
    end
  end

  it "generates an {X} cost" do
    expect(generate("Parsed Burst {X}{R}\nSorcery\nYou gain 1 life.\n")).to include("cost x: 1, red: 1")
  end
end
