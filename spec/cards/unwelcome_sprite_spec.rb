# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UnwelcomeSprite do
  include_context "two player game"

  let!(:sprite) { ResolvePermanent("Unwelcome Sprite", owner: p1) }

  def cast_opt
    p1.add_mana(blue: 1)
    p1.cast(card: Card("Opt")) { _1.pay_mana(blue: 1) }
  end

  def surveil_choices = game.choices.select { _1.is_a?(Magic::Choice::Surveil) }

  it "is a 2/1 Faerie Rogue with flying" do
    expect(sprite.power).to eq(2)
    expect(sprite.toughness).to eq(1)
    expect(sprite.type?("Faerie")).to eq(true)
    expect(sprite.type?("Rogue")).to eq(true)
    expect(sprite.flying?).to eq(true)
  end

  it "surveils 2 when you cast a spell during an opponent's turn" do
    go_to_main_phase_for!(p2)
    cast_opt
    game.settle!

    choice = surveil_choices.first
    expect(choice).not_to be_nil
    expect(choice.amount).to eq(2)
  end

  it "doesn't trigger on your own turn" do
    go_to_main_phase!
    cast_opt
    game.settle!

    expect(surveil_choices).to be_empty
  end

  it "doesn't trigger when an opponent casts a spell" do
    go_to_main_phase_for!(p2)
    p2.add_mana(blue: 1)
    p2.cast(card: Card("Opt")) { _1.pay_mana(blue: 1) }
    game.settle!

    expect(surveil_choices).to be_empty
  end
end
