module ApplicationHelper

  # Adds error to field with that error on forms
  def field_with_errors(object, field_sym)
    unless object.errors[field_sym].empty?
      content_tag(:div, class: "text-danger") do
        "#{field_sym.to_s.titleize} #{object.errors[field_sym].first}"
      end
    end
  end
end
