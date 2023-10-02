# Accidentally worked on two different UsersDbHelper, but implemented now in too many areas.
# So just going to keep separate.
class UsersDbHelper2
  def self.reset
    DB[:sqlite_sequence].truncate
    User_info.dataset.destroy
    User.dataset.destroy
    Subject.dataset.destroy
  end

  def self.create_user
    user = User.new(email: "test1@gmail.com", is_verified: 1, password: BCrypt::Password.create("Test!!123"),
                    is_staff: 0, is_suspended: 0, roles_ids: "1")
    user.save_changes
    subject = Subject.new(name: "Test Subject")
    subject.save_changes
    user_info = User_info.new(user_id: user.id, subject: subject.id, year_of_study: 2, first_name: "George",
                              last_name: "Hum")
    user_info.save_changes
  end

  def self.create_many_users
    user = User.new(email: "test1@gmail.com", is_verified: 1, password: BCrypt::Password.create("Test!!123"),
                    is_staff: 0, is_suspended: 0, roles_ids: "1")
    user.save_changes
    subject = Subject.new(name: "Test Subject")
    subject.save_changes
    user_info = User_info.new(user_id: user.id, subject: subject.id, year_of_study: 2, first_name: "George",
                              last_name: "Hum")
    user_info.save_changes

    user2 = User.new(email: "test2@gmail.com", is_verified: 1, password: BCrypt::Password.create("Test!!123"),
                     is_staff: 1, is_suspended: 0, roles_ids: "3")
    user2.save_changes
    subject2 = Subject.new(name: "Another")
    subject2.save_changes
    user_info2 = User_info.new(user_id: user2.id, subject: subject2.id, year_of_study: 3, first_name: "Robert",
                               last_name: "Hawk")
    user_info2.save_changes

    user3 = User.new(email: "test3@gmail.com", is_verified: 1, password: BCrypt::Password.create("Test!!123"),
                     is_staff: 0, is_suspended: 1, roles_ids: "1")
    user3.save_changes
    subject3 = Subject.new(name: "Astro")
    subject3.save_changes
    user_info3 = User_info.new(user_id: user3.id, subject: subject3.id, year_of_study: 1, first_name: "Jermaine",
                               last_name: "Tom")
    user_info3.save_changes
  end

  def self.create_administrator
    user = User.new(email: "admin@gmail.com", is_verified: 1, password: BCrypt::Password.create("Test!!123"),
                    is_staff: 1, is_suspended: 0, roles_ids: "4")
    user.save_changes
  end

  def self.create_moderator
    user = User.new(email: "moderator@gmail.com", is_verified: 1, password: BCrypt::Password.create("Test!!123"),
                    is_staff: 1, is_suspended: 0, roles_ids: "3")
    user.save_changes
  end
end
