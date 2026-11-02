module Magic
  module Cards
    Glamdring = Equipment("Glamdring") do
      legendary_artifact
      cost generic: 2
      equip [Costs::Mana.new(generic: 3)], sorcery_speed: true
    end

    class Glamdring < Equipment
      # "Equipped creature has first strike..."
      class GrantFirstStrike < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FIRST_STRIKE
        applies_to_target
      end

      # "...and gets +1/+0 for each instant and sorcery card in your graveyard."
      class Buff < Abilities::Static::PowerAndToughnessModification
        def applicable_targets = [source.attached_to].compact

        def power_modification
          source.controller.graveyard.count { _1.instant? || _1.sorcery? }
        end

        def toughness_modification = 0
      end

      def static_abilities = [GrantFirstStrike, Buff]

      # "...you may cast an instant or sorcery spell from your hand with mana value less than or equal to that damage
      # without paying its mana cost."
      class CastChoice < Magic::Choice::Targeted
        def initialize(actor:, damage:)
          @damage = damage
          super(actor: actor)
        end

        def choices = controller.hand.select { (_1.instant? || _1.sorcery?) && _1.mana_value <= @damage }

        def choice_amount = 1

        def targets? = false

        def resolve!(target:)
          Magic::Choice::FreeCast.start(actor: actor, card: target, exile_after: false)
        end

        def decline! = nil
      end

      class MayCast < Magic::Choice::May
        def initialize(actor:, damage:)
          @damage = damage
          super(actor: actor)
        end

        def resolve!
          choice = CastChoice.new(actor: actor, damage: @damage)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # "Whenever equipped creature deals combat damage to a player, ..." The creature comes from the event.
      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.target.is_a?(Magic::Player) && event.source == actor.attached_to && event.damage.positive?
        end

        def call
          choice = CastChoice.new(actor: actor, damage: event.damage)
          game.add_choice(MayCast.new(actor: actor, damage: event.damage)) if choice.choices.any?
        end
      end

      def event_handlers = super.merge({ Events::CombatDamageDealt => CombatDamageTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
