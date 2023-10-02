class Course < Sequel::Model
  def public?
    return true if is_public == 1

    false
  end

  def delete
    self.is_archived = 1
    save_changes
  end

  def restore
    self.is_archived = 0
    save_changes
  end

  def archived?
    is_archived == 1
  end

  def course_load(params)
    self.name = params.fetch("name", "").strip
    self.subject = params.fetch("subject", "").strip.to_i
    self.lecturer = params.fetch("lecturer", "").strip
    self.source_website = params.fetch("source_website", "").strip
    self.start_date = if params.fetch("start_date", "").strip.eql?("")
                        nil
                      else
                        DateParse.parse_date_to_unix(params.fetch("start_date", "1970-01-01"))
                      end
    self.end_date = if params.fetch("end_date", "").strip.eql?("")
                      nil
                    else
                      DateParse.parse_date_to_unix(params.fetch("end_date", "1970-01-01"))
                    end
    self.duration = params.fetch("duration", "0").strip.to_i * 60
    self.description = params.fetch("description", "")
    self.outcomes = params.fetch("outcomes", "").strip.sub(/\r/, "")
    self.is_public = params.fetch("is_public", "").to_i
    self.provider = params.fetch("provider", nil)&.to_i
    self.tags = CourseTag.extract_tags_from_params(params)&.join(";")
  end

  def self.id_exists?(id)
    return false if id.nil? # check the id is not nil
    return false unless Validation.str_is_integer?(id) # check the id is an integer
    return false if Course[id].nil? # check the database has a record with this id

    true # all checks are ok - the id exists
  end

  def validate
    super
    errors.add("name", "cannot be empty") if !name || name.empty?
    errors.add("subject", "cannot be empty") if !subject || !(subject.is_a? Integer) || subject.eql?(0)
    errors.add("lecturer", "cannot contain special characters") if Validation.str_has_special_chars?(lecturer)
    if !source_website || source_website.empty?
      errors.add("source_website", "Please provide with a website for this course!")
    end
    errors.add("description", "cannot be empty") if !description || description.empty?
    errors.add("duration", "cannot be empty and must be an integer") if !duration || !(duration.is_a? Integer) ||
                                                                        duration <= 0
    errors.add("provider", "Selected provider is wrong") if provider && Provider.first(id: provider).nil?
    errors.add("end_date", "cannot be earlier than start date") if start_date && end_date && start_date > end_date
    errors.add("course_tags", "One of selected tags seems not to exist") unless CourseTag.provided_tags_exist?(tags)
  end

  def get_date(date, format)
    DateParse.parse_unix_to_date(date, format)
  end

  def get_start_date(format)
    get_date(start_date, format)
  end

  def get_end_date(format)
    get_date(end_date, format)
  end

  def tag_list
    return nil if tags.nil?

    tags.split(";").map(&:to_i)
  end

  dataset_module do
    def filter_results(params, courses_ids)
      # We get this course instance to apply relevant sql clauses. Depending if the param for a filter is present
      # we just impose that into dataset variable. Finally, we get all courses that fulfill imposed filter clauses
      dataset = self
      dataset = dataset.where(id: courses_ids) if !courses_ids.nil? && courses_ids.is_a?(Array) && !courses_ids.empty?

      if params['hide_private']
        params['providers'] = [] if params['providers'].nil?
        params['viewer_courses'] = [] if params['viewer_courses'].nil?
        dataset = dataset.where do
          Sequel.|({ is_public: 1, is_archived: 0 }, { provider: params['providers'] },
                   { id: params['viewer_courses'], is_archived: 0 })
        end
      end

      name = params['course_name']
      dataset = dataset.where(Sequel.ilike(:name, "%#{name}%")) unless name.nil? || name.eql?("")

      subject = params['subject'] if Subject.first(id: params['subject'])
      dataset = dataset.where(subject: subject) unless subject.nil? || subject.eql?("") ||
                                                       subject.eql?("all")

      start_date = params['start_date']
      start_date_exact = params['start_date_exact']
      unless start_date.nil?
        parsed_date = DateParse.parse_date_to_unix(start_date)
        unless parsed_date.nil?
          # Here we check if "Exact?" checkbox was ticked. If yes we don't get date starting from the given date
          # but only exact date
          dataset = if start_date_exact
                      dataset.where(start_date: parsed_date)
                    else
                      dataset.where(start_date: parsed_date..)
                    end
        end
      end

      end_date = params['end_date']
      end_date_exact = params['end_date_exact']
      unless end_date.nil?
        parsed_end_date = DateParse.parse_date_to_unix(end_date)
        unless parsed_end_date.nil?
          # Here we check if "Exact?" checkbox was ticked. If yes we don't get date starting from the given date
          # but only exact date
          dataset = if end_date_exact
                      dataset.where(end_date: parsed_end_date)
                    else
                      dataset.where(end_date: parsed_end_date..)
                    end
        end
      end

      duration = params['duration']
      dataset = dataset.where(duration: duration) unless duration.nil? || duration.eql?("")

      lecturer = params['lecturer']
      dataset = dataset.where(Sequel.ilike(:lecturer, "%#{lecturer}%")) unless lecturer.nil? ||
                                                                               lecturer.eql?("")

      dataset = dataset.exclude(provider: nil) unless params['provider'].nil?
      dataset.default_order.all
    end

    def most_popular_order
      where(is_public: 1, is_archived: 0).order(Sequel.desc(:signups))
    end

    def default_suggestion_order
      where(is_public: 1, is_archived: 0)
        .order(Sequel.case({ { provider: nil } => 1 }, 0))
        .order_append(Sequel.desc(:signups))
    end

    def default_order
      order(:is_archived).order_append(Sequel.asc(:name))
    end
  end

  def self.get_trending_courses(number_of_courses)
    last_week_ids = StudentCourse.trending_student_courses.map(&:course_id).uniq

    course_list = where(id: last_week_ids).most_popular_order.limit(number_of_courses).all
    return get_popular_courses(number_of_courses) if course_list.empty?

    course_list
  end

  def self.get_popular_courses(number_of_courses)
    most_popular_order.limit(number_of_courses).all
  end

  def self.get_courses_providers(idProvider)
    where(provider: idProvider)
  end
end
