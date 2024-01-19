require 'spec_helper'

RSpec.describe Magic::Cards::Rewind do
  include_context "two player game"

  subject(:rewind) { Card("Rewind") }

  context "counters Sol Ring, untaps four lands" do
    before do
      islands = 4.times.map { ResolvePermanent("Island", owner: p1) }
      islands.each(&:tap!)
    end

    let(:sol_ring) { Card("Sol Ring", owner: p2) }

    before do
      p2.add_mana(blue: 1)
      sol_ring_cast = p2.cast(card: sol_ring) do
        _1.pay_mana(generic: { blue: 1 })
      end

      p1.add_mana(blue: 4)
      p1.cast(card: rewind) do
        _1.pay_mana(generic: { blue: 2}, blue: 2)
        _1.targeting(sol_ring_cast)
      end
      game.tick!
    end

    it "counters target spell if cost is unpaid" do
      expect(sol_ring.zone).to be_graveyard
      islands = p1.permanents.by_name("Island")
      game.resolve_choice!(targets: islands)

      expect(islands).to all(be_untapped)
    end
  end
end
