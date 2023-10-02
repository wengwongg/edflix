get "/staff-contact" do
  @title = "Contact us"
  erb :'pages/user/staff_contact', layout: :'templates/layout'
end

post "/staff-contact" do
  @name = params["name"]
  @email = params["email"]
  @text = params["text"]

  @form_was_submitted = !@name.nil? || !@email.nil? || !@text.nil?

  @name_error = nil
  @email_error = nil
  @text_error = nil

  if @form_was_submitted
    # sanitisation by removing whitespace
    @name.strip!
    @email.strip!
    @text.strip!

    # validation
    @name_error = "Please enter your name" if @name.empty?
    @email_error = "Please enter your email" if @email.empty?
    @text_error = "Please enter a value for text" if @text.empty?
    unless @name_error.nil? && @email_error.nil? && @text_error.nil?
      @submission_error = "Please correct the errors below"
    end
  end

  if !@name.nil? && !@email.nil? && !@text.nil?
    # create a new record
    StaffContact.create_new_event(@name, @email, @text)
  end

  @title = "Contact us"
  erb :'pages/user/staff_contact', layout: :'templates/layout'
end
