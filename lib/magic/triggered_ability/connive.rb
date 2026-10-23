module Magic
  class TriggeredAbility
    # "When this creature enters, it connives." Wired by the `connive :enters` card macro.
    class Connive < TriggeredAbility
      def call = connive
    end
  end
end
