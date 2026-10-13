module Magic
  module Cards
    class MaskOfGriselbrand < Equipment
      card_name "Mask of Griselbrand"
      type T::Super::Legendary, T::Artifact, "Equipment"
      cost generic: 1, black: 2
      equip [Costs::Mana.new(generic: 3)]

      # "Equipped creature has flying and lifelink."
      class KeywordGrants < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FLYING, Keywords::LIFELINK
        applies_to_target
      end

      class PayLifeChoice < Magic::Choice::May
        def initialize(actor:, amount:)
          super(actor: actor)
          @amount = amount
        end

        def prompt = "Pay #{@amount} life to draw #{@amount} cards?"

        def resolve!
          return unless @amount.positive? && controller.life >= @amount

          lose_life(controller, @amount)
          draw_cards(@amount)
        end
      end

      # "Whenever equipped creature dies, you may pay X life, where X is its power. If you do, draw X cards."
      class EquippedCreatureDiesTrigger < TriggeredAbility
        def should_perform? = event.permanent == actor.attached_to

        def call
          game.add_choice(PayLifeChoice.new(actor: actor, amount: [event.permanent.power, 0].max))
        end
      end

      def static_abilities = [KeywordGrants]
      def event_handlers = { Events::CreatureDied => EquippedCreatureDiesTrigger }
    end
  end
end
