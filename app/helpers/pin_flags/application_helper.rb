module PinFlags
  module ApplicationHelper
    def flash_class(type)
      case type.to_s
      when "notice", "success"
        "is-success"
      when "alert", "error"
        "is-danger"
      when "warning"
        "is-warning"
      else
        "is-info"
      end
    end

    def page_title
      content_for?(:title) ? content_for(:title) : "Dashboard"
    end
  end
end
