class StaffContact < Sequel::Model(:staff_contact)
  def self.create_new_event(name, email, text)
    new_event = StaffContact.new(name: name, email: email, text: text, date: DateParse.today_utc_unix)
    new_event.save_changes
  end

  dataset_module do
    def latest_messages
      StaffContact.order(Sequel.desc(:date)).all
    end
  end
end
