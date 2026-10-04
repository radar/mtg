# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # A card in the graveyard moving itself, from a trigger that works from the graveyard
      # (`works_from_graveyard?`, which `Rules::Trigger` reads):
      #
      #   Return ~ from your graveyard to the battlefield.            (Flamewake Phoenix)
      #   Put ~ from your graveyard on top of your library.           (Gate Colossus, after "you may")
      class ReturnThisFromGraveyard < Data.define(:destination)
        include Effect

        LINE = /\A(?:Return ~ from your graveyard to the (?<battlefield>battlefield)|Put ~ from your graveyard on top of your library)\.?\z/i

        def self.parse(text)
          new(destination: $~[:battlefield] ? :battlefield : :top) if LINE.match(text)
        end

        def works_from_graveyard? = true

        def resolve_call
          this = Effect::THIS
          move = if destination == :battlefield
                   "trigger_effect(:return_target_from_graveyard_to_battlefield, target: #{this}, controller: controller)"
                 else
                   "#{this}.move_zone!(to: #{this}.owner.library)"
                 end
          "#{move} if #{this}.zone&.graveyard?"
        end
      end
    end
  end
end
