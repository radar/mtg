require "spec_helper"

RSpec.describe Magic::Cards::MassacreGirl do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves") }
  let!(:alpine_watchdog) { ResolvePermanent("Alpine Watchdog") }

  context "when massacre girl enters the battlefield" do
    it "kills the wood elves and the alpine watchdog" do

      p1.add_mana(black: 5)
      p1.cast(card: Card("Massacre Girl")) do
        _1.auto_pay_mana
      end

      game.stack.resolve!

      # This dies to the ETB -1/-1 triggered ability
      expect(wood_elves.card.zone).to be_graveyard
      # This dies to the "creature died" -1/-1 triggered ability
      expect(alpine_watchdog.card.zone).to be_graveyard
    end
  end
end
