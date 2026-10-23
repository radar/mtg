module Magic
  class TriggeredAbility
    # "When this creature enters, it connives." Wired by the `connive :enters` card macro.
    class Connive < TriggeredAbility
      def call = connive
    end

    # "Whenever this creature attacks, it connives." Wired by the `connive :attacks` card macro.
    class ConniveOnAttack < Connive
      def should_perform? = event.attacks.any? { _1.attacker == actor }
    end
  end
end
