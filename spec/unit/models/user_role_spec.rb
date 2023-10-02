require_relative "../../spec_helper"

RSpec.describe UserRole do
  describe "get_user_roles method" do
    context "when user is nil or not valid" do
      it "returns nil if user is nil" do
        returned_roles = described_class.get_user_roles(nil)
        expect(returned_roles).to be_nil
      end

      it "throws RuntimeError if user has no roles" do
        user = User.new(email: "test100@test.eu", is_verified: 0,
                        password: "$2a$12$U9yi6WCtTKGZ0BDuIUVXceXf/PPSZO5idsqbpqWqDNDdniqR2PK3u")
        expect { described_class.get_user_roles(user) }.to raise_error(RuntimeError,
                                                                       "Unknown roles. User must have at least one role.")
      end

      it "returns nil if user has non-existing role" do
        user = User.new(email: "test100@test.eu", is_verified: 0,
                        password: "$2a$12$U9yi6WCtTKGZ0BDuIUVXceXf/PPSZO5idsqbpqWqDNDdniqR2PK3u", roles_ids: "100")
        expect(described_class.get_user_roles(user)).to be_nil
      end
    end

    context "when user is valid and has valid roles" do
      it "returns role named provider only if user has roles_ids=2" do
        user = User.new(email: "test100@test.eu", is_verified: 0,
                        password: "$2a$12$U9yi6WCtTKGZ0BDuIUVXceXf/PPSZO5idsqbpqWqDNDdniqR2PK3u", roles_ids: "2")
        expect(described_class.get_user_roles(user).map(&:name)).to contain_exactly("provider")
      end

      it "returns role named student only if user has roles_ids=1" do
        user = User.new(email: "test100@test.eu", is_verified: 0,
                        password: "$2a$12$U9yi6WCtTKGZ0BDuIUVXceXf/PPSZO5idsqbpqWqDNDdniqR2PK3u", roles_ids: "1")
        expect(described_class.get_user_roles(user).map(&:name)).to contain_exactly("student")
      end

      it "returns roles named student and moderator if user has roles_ids=1;3" do
        user = User.new(email: "test100@test.eu", is_verified: 0,
                        password: "$2a$12$U9yi6WCtTKGZ0BDuIUVXceXf/PPSZO5idsqbpqWqDNDdniqR2PK3u", roles_ids: "1;3")
        expect(described_class.get_user_roles(user).map(&:name)).to contain_exactly("student", "moderator")
      end
    end
  end

  describe "get_user_policies method" do
    context "when provided roles are not valid" do
      it "returns nil if provided param (roles) is nil" do
        expect(described_class.get_user_policies(nil)).to be_nil
      end

      it "returns nil if provided roles param is not an array" do
        expect(described_class.get_user_policies("something")).to be_nil
      end

      it "returns nil if provided roles are empty array" do
        expect(described_class.get_user_policies([])).to be_nil
      end

      it "nil if provided role has no policies" do
        role = Role.new(name: "test role")
        expect(described_class.get_user_policies([role])).to be_nil
      end
    end

    context "when provided roles are valid" do
      it "returns empty array if provided policies do not exist if policies=100" do
        role = Role.new(name: "test role", policies: "100")
        expect(described_class.get_user_policies([role])).to match_array([])
      end

      it "returns array with policy named 'view_courses' if policies=1" do
        role = Role.new(name: "test role", policies: "1")
        expect(described_class.get_user_policies([role]).map(&:name)).to contain_exactly("view_courses")
      end

      it "returns array with policies: 'view_courses', 'manage_courses' if policies=1;3" do
        role = Role.new(name: "test role", policies: "1;3")
        expect(described_class.get_user_policies([role]).map(&:name)).to contain_exactly(
          "view_courses", "manage_courses"
        )
      end

      it "returns array with policies: 'view_courses', 'provide_courses', 'add_reviews' if given roles are student and provider" do
        expect(described_class.get_user_policies(Role.where(id: [1, 2]).all).map(&:name)).to contain_exactly(
          "view_courses", "provide_courses", "use_reviews", "provide_tags", "provide_subjects", "suggest_courses"
        )
      end
    end
  end

  describe "get_user_permissions method" do
    context "when provided policies are not valid" do
      it "returns nil if provided policies is nil" do
        expect(described_class.get_user_permissions(nil)).to be_nil
      end

      it "returns nil if provided policies is not an array" do
        expect(described_class.get_user_permissions("something")).to be_nil
      end

      it "returns nil if provided policies is an empty array" do
        expect(described_class.get_user_permissions([])).to be_nil
      end

      it "returns nil if provided policy has no permissions" do
        policy = Policy.new(name: "test name")
        expect(described_class.get_user_permissions([policy])).to be_nil
      end
    end

    context "when provided policies are valid" do
      it "returns array containing 'test.perm'" do
        policy = Policy.new(name: "test name", permissions: 'test.perm')
        expect(described_class.get_user_permissions([policy])).to contain_exactly("test.perm")
      end

      it "returns array containing 'test.perm' and 'test.second'" do
        policy = Policy.new(name: "test name", permissions: 'test.perm;test.second')
        expect(described_class.get_user_permissions([policy])).to contain_exactly("test.perm", "test.second")
      end

      it "returns array containing 'policy1.perm' and 'policy2.perm'" do
        policy1 = Policy.new(name: "test name", permissions: 'policy1.perm')
        policy2 = Policy.new(name: "test2 name", permissions: 'policy2.perm')
        expect(described_class.get_user_permissions([policy1, policy2])).to contain_exactly(
          "policy1.perm", "policy2.perm"
        )
      end
    end
  end

  describe "has_user_permission? method" do
    context "when passed params are not valid" do
      it "returns false if both params are nil" do
        expect(described_class.has_user_permission?(nil, nil)).to be(false)
      end

      it "returns false if only user is nil" do
        expect(described_class.has_user_permission?(nil, "courses.view")).to be(false)
      end

      it "returns false if only permission is nil" do
        DbHelper.set_main_tables(false, true)
        expect(described_class.has_user_permission?(User.first(id: 1), nil)).to be(false)
      end

      it "throws RuntimeError if user has no roles" do
        user = User.new(email: "test100@test.eu", is_verified: 0,
                        password: "$2a$12$U9yi6WCtTKGZ0BDuIUVXceXf/PPSZO5idsqbpqWqDNDdniqR2PK3u")
        expect { described_class.has_user_permission?(user, "courses.view") }.to raise_error(
          RuntimeError, "Unknown roles. User must have at least one role."
        )
      end

      it "returns false if user has only one role and the role does not contain any policies" do
        user = User.new(email: "test100@test.eu", is_verified: 0,
                        password: "$2a$12$U9yi6WCtTKGZ0BDuIUVXceXf/PPSZO5idsqbpqWqDNDdniqR2PK3u", roles_ids: "4")
        role = Role.new(name: "test name")
        role.save_changes
        expect(described_class.has_user_permission?(user, "courses.view")).to be(false)
      end
    end

    context "when passed params are valid" do
      it "returns false if user does not possess given permission" do
        user = User.new(email: "test100@test.eu", is_verified: 0,
                        password: "$2a$12$U9yi6WCtTKGZ0BDuIUVXceXf/PPSZO5idsqbpqWqDNDdniqR2PK3u", roles_ids: "1")
        expect(described_class.has_user_permission?(user, "courses.delete")).to be(false)
      end

      it "returns true if user possesses given permission" do
        user = User.new(email: "test100@test.eu", is_verified: 0,
                        password: "$2a$12$U9yi6WCtTKGZ0BDuIUVXceXf/PPSZO5idsqbpqWqDNDdniqR2PK3u", roles_ids: "1")
        expect(described_class.has_user_permission?(user, "courses.user.view")).to be(true)
      end
    end
  end
end
