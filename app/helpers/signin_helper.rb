module SigninHelper
  # フラッシュメッセージの表示
  def display_flash_messages
    messages = []

    if flash[:alert]
      messages << content_tag(:div, flash[:alert],
                            style: "color: red; margin-bottom: 10px;",
                            class: "flash-alert")
    end

    if flash[:notice]
      messages << content_tag(:div, flash[:notice],
                            style: "color: green; margin-bottom: 10px;",
                            class: "flash-notice")
    end

    messages.join.html_safe
  end

  # サインインフォームのエラー表示
  def display_signin_errors(user)
    return "" unless user&.errors&.any?

    content_tag :div, style: "color: red; margin-bottom: 15px;", class: "signin-errors" do
      content_tag(:h4, "エラーがあります:") +
      content_tag(:ul) do
        user.errors.full_messages.map do |msg|
          content_tag(:li, msg)
        end.join.html_safe
      end
    end
  end

  # サインインフォームの整形
  def signin_form_field(form, field_type, field_name, options = {})
    default_options = {
      required: true,
      class: "form-input"
    }

    merged_options = default_options.merge(options)

    case field_type
    when :text
      form.text_field field_name, merged_options
    when :password
      form.password_field field_name, merged_options
    else
      form.text_field field_name, merged_options
    end
  end
end
