# frozen_string_literal: true

require "spec_helper"

# Every Bloomburrow card implemented so far must load and match its Oracle name, mana value
# and power/toughness. Behaviour specs for individual cards live in their own files.
RSpec.describe "Bloomburrow cards" do
  include_context "two player game"

  oracle = Magic::Oracle.new
  names = File.readlines(File.expand_path("../fixtures/bloomburrow_names.txt", __dir__), chomp: true)

  names.each do |name|
    describe name do
      let(:data) { oracle.find_card(name) }
      let(:permanent) { ResolvePermanent(card_name, owner: p1, settle: false) }
      let(:card_name) { name.gsub(/(\A|[ -])[a-z]/) { _1.upcase } }
      let(:card) { Card(name.gsub(/(\A|[ -])[a-z]/) { _1.upcase }, owner: p1) }

      it "matches Oracle name and mana value" do
        expect(card.name).to eq(name)
        cmc = data["mana_cost"].to_s.scan(/\{(\w+)[^}]*\}/).sum { |(s)| s =~ /\A\d+\z/ ? s.to_i : (s == "X" ? 0 : 1) }
        expect(card.mana_value).to eq(cmc)
      end

      it "matches Oracle power and toughness", if: oracle.find_card(name)["power"] do
        expect(permanent.power.to_s).to eq(data["power"])
        expect(permanent.toughness.to_s).to eq(data["toughness"])
      end
    end
  end
end
