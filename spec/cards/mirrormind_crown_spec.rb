# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MirrormindCrown do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:crown) { ResolvePermanent("Mirrormind Crown", owner: p1) }
  let!(:courser) { ResolvePermanent("Courser Of Kruphix", owner: p1) }

  def make_tokens(amount = 1)
    courser.trigger_effect(:create_token, token_class: Magic::Cards::Kinbinding::KithkinToken, amount:)
    game.settle!
  end

  def tokens_named(name) = p1.creatures.select { _1.token? && _1.name == name }

  it "creates ordinary tokens while unattached" do
    make_tokens

    expect(tokens_named("Kithkin").size).to eq(1)
  end

  context "attached to a creature" do
    before { crown.attach_to!(courser) }

    it "creates token copies of the equipped creature instead, the first time each turn" do
      make_tokens

      expect(tokens_named("Kithkin")).to be_empty
      expect(tokens_named("Courser of Kruphix").size).to eq(1)
    end

    it "creates that many copies for several tokens" do
      make_tokens(3)

      expect(tokens_named("Courser of Kruphix").size).to eq(3)
    end

    it "only replaces the first time each turn" do
      make_tokens
      make_tokens

      expect(tokens_named("Kithkin").size).to eq(1)
      expect(tokens_named("Courser of Kruphix").size).to eq(1)
    end

    it "applies again the next turn" do
      make_tokens
      current_turn.end!
      current_turn.cleanup!
      make_tokens

      expect(tokens_named("Courser of Kruphix").size).to eq(2)
    end

    it "does not replace the opponent's tokens" do
      go_to_main_phase_for!(p2)
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      theirs.trigger_effect(:create_token, token_class: Magic::Cards::Kinbinding::KithkinToken)
      game.settle!

      expect(p2.creatures.count(&:token?)).to eq(1)
      expect(p2.creatures.find(&:token?).name).to eq("Kithkin")
    end
  end

  it "can equip for {2}" do
    p1.add_mana(green: 2)
    p1.activate_ability(ability: crown.activated_abilities.first) { _1.pay_mana(generic: { green: 2 }).targeting(courser) }
    game.stack.resolve!

    expect(crown.attached_to).to eq(courser)
  end
end
