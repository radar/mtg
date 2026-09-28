# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HexingSquelcher do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:squelcher) { ResolvePermanent("Hexing Squelcher", owner: p1) }

  def cast_at(target, player: p2)
    player.add_mana(red: 1)
    player.cast(card: Card("Shock", owner: player)) { _1.pay_mana(red: 1).targeting(target) }
    game.settle!
  end

  it "can't be countered itself" do
    expect(Card("Hexing Squelcher", owner: p1).can_be_countered?).to eq(false)
  end

  it "stops spells you control being countered, but not an opponent's" do
    mine = Card("Shock", owner: p1)
    theirs = Card("Shock", owner: p2)
    p1.hand.add(mine)
    p2.hand.add(theirs)

    expect(mine.can_be_countered?).to eq(false)
    expect(theirs.can_be_countered?).to eq(true)
  end

  describe "Ward—Pay 2 life" do
    it "asks an opponent targeting it to pay 2 life" do
      cast_at(squelcher)

      choice = game.choices.last
      expect(choice).to be_a(Magic::Choice::Ward)
      game.resolve_choice!(pay_life: true)
      game.settle!

      expect(p2.life).to eq(18)
      expect(squelcher.damage).to eq(2)
    end

    it "counters the spell unless they pay" do
      cast_at(squelcher)
      game.resolve_choice!(pay_life: false)
      game.settle!

      expect(p2.life).to eq(20)
      expect(squelcher.damage).to eq(0)
    end

    it "can't be paid with less than 2 life" do
      p2.instance_variable_set(:@life, 1)
      cast_at(squelcher)
      game.resolve_choice!(pay_life: true)
      game.settle!

      expect(p2.life).to eq(1)
      expect(squelcher.damage).to eq(0)
    end

    it "does not ward against its controller" do
      cast_at(squelcher, player: p1)

      expect(game.choices).to be_empty
    end
  end

  describe "other creatures you control have Ward—Pay 2 life" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "asks an opponent targeting one to pay 2 life or be countered" do
      cast_at(bears)

      expect(game.choices.last).to be_a(Magic::Choice::Ward)
      game.resolve_choice!(pay_life: true)
      game.settle!

      expect(p2.life).to eq(18)
      expect(bears.damage).to eq(2)
    end

    it "counters the spell if they don't pay" do
      cast_at(bears)
      game.resolve_choice!(pay_life: false)
      game.settle!

      expect(p2.life).to eq(20)
      expect(bears.damage).to eq(0)
    end

    it "does not ward an opponent's creature" do
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      cast_at(theirs, player: p1)

      expect(game.choices).to be_empty
    end

    it "does not ward against its controller" do
      cast_at(bears, player: p1)

      expect(game.choices).to be_empty
    end
  end
end
