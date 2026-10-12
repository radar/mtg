module Magic
  module Cards
    class ArtistsTalent < ClassEnchantment
      card_name "Artist's Talent"
      cost generic: 1, red: 1
      level_costs 2 => "{2}{R}", 3 => "{2}{R}"

      # Whenever you cast a noncreature spell, you may discard a card. If you do, draw a card.
      class CastTrigger < TriggeredAbility::SpellCast
        class DiscardChoice < Magic::Choice::Discard
          def resolve!(card:)
            super
            draw_card
          end
        end

        class MayChoice < Magic::Choice::May
          def resolve!
            game.choices.add(DiscardChoice.new(actor: actor, player: controller))
          end
        end

        def should_perform? = event.player == controller && !spell.creature?

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def event_handlers = super.merge(Events::SpellCast => CastTrigger)

      # Level 2: Noncreature spells you cast cost {1} less to cast.
      class ReduceManaCost < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          @source = source
          @adjustment = { generic: -1 }
        end

        def applies_to?(card) = source.level >= 2 && card.controller == source.controller && !card.creature?
      end

      def static_abilities = [ReduceManaCost]

      # Level 3: If a source you control would deal noncombat damage to an opponent or a permanent an
      # opponent controls, it deals that much damage plus 2 instead.
      class DamageBoost < ReplacementEffect::DamageIncreaser
        def self.registrations = [[Effects::DealDamage, self]]

        def increase = 2

        def applies?(effect) = receiver.level >= 3 && super

        private

        def recipient_applies?(target) = damaged_player(target) != receiver.controller
      end

      def replacement_effects = DamageBoost.registrations
    end
  end
end
