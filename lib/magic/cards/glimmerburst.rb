module Magic
  module Cards
    Glimmerburst = Instant("Glimmerburst") do
      cost generic: 3, blue: 1
    end

    class Glimmerburst < Instant
      # "Draw two cards. Create a 1/1 white Glimmer enchantment creature token."
      def resolve!
        trigger_effect(:draw_cards, number_to_draw: 2)
        trigger_effect(:create_token, token_class: GlimmerSeeker::GlimmerToken)

        super
      end
    end
  end
end
