# frozen_string_literal: true

module FlashHelper
  def toasts
    flash.select { |_, value| value.is_a?(Hash) }
  end

  def alert
    value = flash[:alert]
    value unless value.is_a?(Hash)
  end

  def notice
    value = flash[:notice]
    value unless value.is_a?(Hash)
  end
end
