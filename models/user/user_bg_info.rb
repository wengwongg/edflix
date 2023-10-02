class User_info < Sequel::Model
  def get_first_name
    first_name.to_s
  end

  def get_last_name
    last_name.to_s
  end

  def get_year_of_study
    year_of_study.to_s
  end

  def get_subject
    subject.to_s
  end

  def self.create_user_info(subject, year, first_name, last_name, user_id)
    new_user_info = User_info.new(subject: subject, year_of_study: year, first_name: first_name,
                                  last_name: last_name, user_id: user_id)
    new_user_info.save_changes
  end

  def user_info_load(subject, year, first_name, last_name)
    self.subject = subject
    self.year_of_study = year
    self.first_name = first_name
    self.last_name = last_name
  end
end
