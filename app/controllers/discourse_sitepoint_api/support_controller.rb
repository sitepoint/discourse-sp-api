module DiscourseSitepointApi
  class SupportController < ApplicationController

    before_action :ensure_logged_in
    before_action :ensure_staff

    def daily_log_outs
      users = UserCustomField.joins(:user)
        .select("users.id, users.email, value::timestamp AS last_logged_out_at")
        .where("user_custom_fields.name = 'last_logged_out_at' AND value::timestamp > CURRENT_DATE - INTERVAL '1' DAY AND last_seen_at <= value::timestamp")

      render json: {users: users}, status: 200
    end

    # TODO only for staging testing - remove this after the fact!
    # preview notes migration
    def pnm
      # Purge staff_notes and start the import from scratch
      PluginStoreRow.where(plugin_name: "staff_notes").destroy_all

      UserCustomField.where(name: "staff_notes_count").destroy_all

      # Import legacy profile_notes
      PluginStoreRow.where(plugin_name: "profile_notes").find_each do |row|
        puts "Row_Key: #{row.key}"

        user_id = row.key.split("_").third

        unless User.exists?(user_id)
          puts "User not found (skipping)..."
          next
        else
          user = User.find(user_id)
        end

        value = JSON.parse(row.value)

        notes = value["notes"]

        if notes.blank?
          puts "Notes are empty (skipping)..."
          next
        end

        puts "Migrating notes for #{user.username}: #{notes}"

        notes.each { |n| add_note(user, n) }
      end

      render json: { count: PluginStoreRow.where(plugin_name: "staff_notes").count }
    end

    private

    def raw(note)
      return note["text"] unless note["topic_id"]

      topic = Topic.find_by(id: note["topic_id"])

      return note["text"] if topic.blank?

      # Append "Your post in ..." topic to the raw note
      note["text"] += "\n\n--[#{topic.title}](#{topic.url})"
    end

    def add_note(user, note)
      notes = PluginStore.get('staff_notes', "notes:#{user.id}") || []
      record = { id: SecureRandom.hex(16), user_id: user.id, raw: raw(note), created_by: note["by"], created_at: note["timestamp"] }
      notes << record
      ::PluginStore.set("staff_notes", "notes:#{user.id}", notes)

      user.custom_fields["staff_notes_count"] = notes.size
      user.save_custom_fields
    end

  end
end

