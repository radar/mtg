module Magic
  class TriggeredAbility
    # Extort (rule 702.101): "Whenever you cast a spell, you may pay {W/B}. If you do, each opponent loses 1 life and
    # you gain that much life." A card lists it as `def event_handlers = { Events::SpellCast => TriggeredAbility::Extort }`.
    class Extort < SpellCast
      class PayChoice < Magic::Choice::PayMana
        def initialize(actor:)
          super(actor: actor, mana: { white_or_black: 1 })
        end

        def resolve!(**)
          super
          lost = game.opponents(chooser).sum do |opponent|
            before = opponent.life
            opponent.lose_life(1)
            before - opponent.life
          end
          chooser.gain_life(lost)
        end
      end

      def should_perform? = event.player == controller

      def call
        choice = PayChoice.new(actor: actor)
        game.add_choice(choice) if choice.can_pay?
      end
    end
  end
end
