class Subject < Sequel::Model
  def self.create(name)
    return false if name.nil? || name.empty? || !Subject.first(name: name).nil? || Validation.str_has_special_chars?(name)

    Subject.new(name: name).save_changes
    true
  end

  def change_name(name)
    return false if name.nil? || name.empty? || Validation.str_has_special_chars?(name) || !Subject.first(name: name).nil?

    set(name: name).save_changes
    true
  end

  def convert_subject_id(subject_id)
    find_subject = Subject.first(id: subject_id)
    if find_subject.nil?
      "null"
    else
      find_subject.name
    end
  end
end
