module Magic
  module Cards
    ThievesGuildEnforcer = Creature("Thieves' Guild Enforcer") do
      cost black: 1
      creature_type "Human Rogue"
      keywords :flash
      power 1
      toughness 1
    end

    class ThievesGuildEnforcer < Creature
      # "Whenever this creature or another Rogue you control enters, each opponent mills two cards."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = under_your_control? && type?("Rogue")

        def call
          opponents.each { |opponent| opponent.mill(2) }
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => EntersTrigger }

      # "As long as an opponent has eight or more cards in their graveyard, this creature gets +2/+1 and has
      # deathtouch."
      def self.opponent_graveyard_full?(ability)
        ability.game.opponents(ability.controller).any? { |opponent| opponent.graveyard.cards.count >= 8 }
      end

      class SelfBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 1
        applicable_targets { [source] }
        conditions { ThievesGuildEnforcer.opponent_graveyard_full?(self) }
      end

      class SelfDeathtouch < Abilities::Static::KeywordGrant
        keyword_grants Keywords::DEATHTOUCH
        applicable_targets { [source] }
        conditions { ThievesGuildEnforcer.opponent_graveyard_full?(self) }
      end

      def static_abilities = [SelfBuff, SelfDeathtouch]
    end
  end
end
