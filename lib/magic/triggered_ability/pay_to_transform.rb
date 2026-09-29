module Magic
  class TriggeredAbility
    # "At the beginning of your first main phase, you may pay {R}. If you do, transform ~."
    # Subclass with `pay red: 1`, and list it under `Events::FirstMainPhase` in `event_handlers`.
    class PayToTransform < TriggeredAbility
      def self.pay(mana)
        define_method(:mana) { mana }
      end

      def should_perform?
        event.active_player == controller
      end

      def call
        game.choices.add(Choice::PayToTransform.new(actor:, mana:)) if Costs::Mana.new(mana).can_pay?(controller)
      end
    end
  end
end
