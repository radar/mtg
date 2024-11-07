require 'spec_helper'

RSpec.describe Magic::Cards::BogBadger do
  include_context "two player game"

  subject { Card("Bog Badger") }
  let!(:loxodon_wayfarer) { ResolvePermanent("Loxodon Wayfarer", owner: p1) }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

  context "resolution" do
    it "kicker cost paid" do
      p1.add_mana(green: 3, black: 1)
      action = cast_action(card: subject, player: p1)
      action.pay_mana(green: 1, generic: { green: 2 })
      action.pay_kicker(black: 1)
      game.take_action(action)
      game.stack.resolve!

      creatures = p1.creatures
      expect(creatures.all? { |c| c.has_keyword?(:menace) }).to eq(true)

      expect(wood_elves.has_keyword?(:menace)).to eq(false)
    end

    it "kicker cost not paid" do
      p1.add_mana(green: 3, black: 1)
      action = cast_action(card: subject, player: p1)
      action.pay_mana(green: 1, generic: { green: 2 })
      game.take_action(action)
      game.stack.resolve!

      creatures = p1.creatures
      expect(creatures.all? { |c| c.has_keyword?(:menace) }).to eq(false)
      expect(wood_elves.has_keyword?(:menace)).to eq(false)
    end
  end
end
