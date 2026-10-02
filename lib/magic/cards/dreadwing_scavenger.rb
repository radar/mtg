module Magic
  module Cards
    DreadwingScavenger = Creature("Dreadwing Scavenger") do
      cost generic: 1, blue: 1, black: 1
      creature_type("Nightmare Bird")
      keywords :flying
      power 2
      toughness 2
    end

    class DreadwingScavenger < Creature
      class SelfBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applicable_targets { [source] }
        conditions { controller.graveyard.cards.count >= 7 }
      end

      class SelfKeywords < Abilities::Static::KeywordGrant
        keyword_grants Keywords::DEATHTOUCH
        applicable_targets { [source] }
        conditions { controller.graveyard.cards.count >= 7 }
      end

      def static_abilities = [SelfBuff, SelfKeywords]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:draw_card)
          game.choices.add(Magic::Choice::Discard.new(actor: actor, player: controller))
        end
      end

      def etb_triggers = [EntersTrigger]

      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        def call
          trigger_effect(:draw_card)
          game.choices.add(Magic::Choice::Discard.new(actor: actor, player: controller))
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttacksTrigger }
    end
  end
end
