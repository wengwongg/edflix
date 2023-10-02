class UsersDbHelper
  def self.reset
    DB[:sqlite_sequence].where(name: "user_infos").delete
    DB[:sqlite_sequence].where(name: "users").delete
    DB.run("PRAGMA foreign_keys = OFF")
    DB[:user_infos].delete
    DB[:student_courses].delete
    DB[:users].delete
    DB.run("PRAGMA foreign_keys = ON")
  end

  def self.create_users
    user1 = User.new(email: "test2@test.eu", is_verified: 0,
                     password: "$2a$12$U9yi6WCtTKGZ0BDuIUVXceXf/PPSZO5idsqbpqWqDNDdniqR2PK3u")
    user2 = User.new(email: "test@test.eu", is_verified: 0, password: "$2a$12$rbgLBaENJHFlc3yPg5YjtuU9.XjEsdejZHOG78clTp/gJ/jTm3ArK",
                     roles_ids: "2", provider_ids: "1")
    user3 = User.new(email: "test3@test.eu", is_verified: 0, password: "$2a$12$U9yi6WCtTKGZ0BDuIUVXceXf/PPSZO5idsqbpqWqDNDdniqR2PK3u",
                     roles_ids: "3")
    user4 = User.new(email: "testmanager@test.eu", is_verified: 0, password: "$2a$12$U9yi6WCtTKGZ0BDuIUVXceXf/PPSZO5idsqbpqWqDNDdniqR2PK3u",
                     roles_ids: "5")
    user1.save_changes
    user2.save_changes
    user3.save_changes
    user4.save_changes
  end

  def self.reset_providers
    DB[:sqlite_sequence].where(name: "providers").delete
    Provider.dataset.destroy
  end

  def self.create_providers
    Provider.new(name: "Test provider").save_changes
    Provider.new(name: "Test provider2").save_changes
  end
end
