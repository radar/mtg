module Magic
  module Cards
    TraitorousGreed = Sorcery("Traitorous Greed") do
      cost generic: 3, red: 1
    end

    class TraitorousGreed < Sorcery
      # "Add two mana of any one color."
      class ManaChoice < Magic::Choice
        def modes
          {
            white: "Add {W}{W}",
            blue: "Add {U}{U}",
            black: "Add {B}{B}",
            red: "Add {R}{R}",
            green: "Add {G}{G}"
          }
        end

        def resolve!(mode:)
          controller.add_mana(mode => 2)
        end
      end

      def target_choices = battlefield.creatures

      # "Gain control of target creature until end of turn. Untap that creature. It gains haste
      # until end of turn. Add two mana of any one color."
      def resolve!(target:)
        target.gain_control_until_eot!(controller)
        target.untap!
        trigger_effect(:grant_keyword, target:, keyword: :haste)
        game.add_choice(ManaChoice.new(actor: self))
      end
    end
  end
end
