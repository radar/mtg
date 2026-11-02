module Magic
  module Cards
    StingTheGlintingDagger = Equipment("Sting, the Glinting Dagger") do
      legendary_artifact
      cost generic: 2
      equip [Costs::Mana.new(generic: 2)], sorcery_speed: true
    end

    class StingTheGlintingDagger < Equipment
      # "Equipped creature gets +1/+1 and has haste."
      class Buff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applies_to_target
      end

      class GrantHaste < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HASTE
        applies_to_target
      end

      # "Equipped creature has first strike as long as it's blocking or blocked by a Goblin or Orc."
      class ConditionalFirstStrike < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FIRST_STRIKE

        def applicable_targets
          creature = source.attached_to
          return [] unless creature && goblin_or_orc_opposed?(creature)

          [creature]
        end

        private

        def goblin_or_orc_opposed?(creature)
          combat = game.current_turn.combat
          return false unless combat

          blocked_attackers = combat.attacks_blocked_by(creature).map(&:attacker)
          blockers = combat.attack_for_attacker(creature)&.remaining_blockers || []
          (blocked_attackers + blockers).any? { _1.type?("Goblin") || _1.type?("Orc") }
        end
      end

      def static_abilities = [Buff, GrantHaste, ConditionalFirstStrike]

      # "At the beginning of each combat, untap equipped creature."
      class UntapTrigger < TriggeredAbility
        def should_perform? = !actor.attached_to.nil?

        def call
          creature = actor.attached_to
          creature.untap! if creature
        end
      end

      def event_handlers = super.merge({ Events::BeginningOfCombat => UntapTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
