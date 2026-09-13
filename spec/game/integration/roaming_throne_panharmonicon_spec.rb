require "spec_helper"

RSpec.describe Magic::Game, "Roaming Throne + Panharmonicon" do
  include_context "two player game"

  let!(:panharmonicon) { ResolvePermanent("Panharmonicon", owner: p1) }
  let!(:throne) { ResolvePermanent("Roaming Throne", owner: p1) }
  let!(:elderfang_ritualist) { ResolvePermanent("Elderfang Ritualist", owner: p1) }

  context "when Roaming Throne's chosen type matches the entering creature" do
    before do
      game.resolve_choice!(creature_type: "Elf")
      game.tick!
    end

    it "triggers the ETB ability three times: once normally, once for Roaming Throne (matching type), and once for Panharmonicon (creature entering)" do
      # Dwynen's Elite creates one 1/1 Elf Warrior token on ETB (it controls another
      # Elf, Elderfang Ritualist). Both Roaming Throne (an Elf-type match) and
      # Panharmonicon (a creature entering) independently cause that same ETB
      # trigger to fire an additional time, on top of its normal single firing --
      # three firings in total, each creating one token.
      ResolvePermanent("Dwynen's Elite", owner: p1)

      tokens = p1.creatures.by_name("Elf Warrior")
      expect(tokens.count).to eq(3)
    end
  end

  context "when Roaming Throne's chosen type does not match the entering creature" do
    before do
      game.resolve_choice!(creature_type: "Merfolk")
      game.tick!
    end

    it "triggers the ETB ability twice: once normally, once for Panharmonicon only" do
      ResolvePermanent("Dwynen's Elite", owner: p1)

      tokens = p1.creatures.by_name("Elf Warrior")
      expect(tokens.count).to eq(2)
    end
  end
end
