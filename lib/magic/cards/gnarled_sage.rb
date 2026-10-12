module Magic
  module Cards
    GnarledSage = Creature("Gnarled Sage") do
      cost generic: 3, green: 2
      creature_type "Treefolk Druid"
      keywords :reach
      power 4
      toughness 4
    end

    class GnarledSage < Creature
      # "As long as you've drawn two or more cards this turn, this creature gets +0/+2 and has vigilance."
      def self.drawn_two_or_more?(ability)
        ability.game.current_turn.events.count { |e| e.is_a?(Events::CardDraw) && e.player == ability.controller } >= 2
      end

      class SelfBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 0, toughness: 2
        applicable_targets { [source] }
        conditions { GnarledSage.drawn_two_or_more?(self) }
      end

      class SelfVigilance < Abilities::Static::KeywordGrant
        keyword_grants Keywords::VIGILANCE
        applicable_targets { [source] }
        conditions { GnarledSage.drawn_two_or_more?(self) }
      end

      def static_abilities = [SelfBuff, SelfVigilance]
    end
  end
end
