# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ProwessOfTheFair do
  include_context "two player game"

  subject!(:prowess) { ResolvePermanent("Prowess Of The Fair", owner: p1) }

  it "is a kindred Elf enchantment" do
    expect(prowess).to be_enchantment
    expect(prowess.type?("Kindred")).to eq(true)
    expect(prowess.type?("Elf")).to eq(true)
  end

  context "when another nontoken Elf you control dies" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

    it "offers a may choice to create an Elf Warrior token" do
      wood_elves.destroy!
      game.settle!

      expect(game.choices.last).to be_a(described_class::CreateTokenChoice)
      game.resolve_choice!

      token = creatures.by_name("Elf Warrior").first
      expect(token).not_to be_nil
      expect(token.power).to eq(1)
      expect(token.toughness).to eq(1)
      expect(token.colors).to eq([:green])
      expect(token).to be_token
    end

    it "does nothing if the choice is declined" do
      wood_elves.destroy!
      game.skip_choice!

      expect(creatures.by_name("Elf Warrior")).to be_empty
    end
  end

  context "when a nontoken Elf an opponent controls dies" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

    it "does not trigger" do
      wood_elves.destroy!

      expect(game.choices.last).not_to be_a(described_class::CreateTokenChoice)
    end
  end

  context "when a token Elf you control dies" do
    let!(:token_elf) { ResolvePermanent("Wood Elves", owner: p1, token: true, copy: true) }

    it "does not trigger" do
      token_elf.destroy!

      expect(game.choices.last).not_to be_a(described_class::CreateTokenChoice)
    end
  end

  context "when a nontoken non-Elf creature you control dies" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "does not trigger" do
      bears.destroy!

      expect(game.choices.last).not_to be_a(described_class::CreateTokenChoice)
    end
  end

  context "when this enchantment leaves the battlefield" do
    it "does not trigger for itself" do
      prowess.destroy!

      expect(game.choices.last).not_to be_a(described_class::CreateTokenChoice)
    end
  end
end
