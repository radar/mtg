module Magic
  module Cards
    Goatnap = Sorcery("Goatnap") do
      cost generic: 2, red: 1
    end

    class Goatnap < Sorcery
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        target.gain_control_until_eot!(controller)
        target.untap!
        trigger_effect(:grant_keyword, target: target, keyword: :haste)
        if target.type?("Goat")
          trigger_effect(:modify_power_toughness, target: target, power: 3, toughness: 0)
        end
      end
    end
  end
end
