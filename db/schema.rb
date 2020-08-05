# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200805150020) do

  create_table "announcements", force: :cascade do |t|
    t.text     "content"
    t.boolean  "restrict_to_staff", default: false
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["end_at"], name: "index_announcements_on_end_at"
    t.index ["restrict_to_staff"], name: "index_announcements_on_restrict_to_staff"
    t.index ["start_at"], name: "index_announcements_on_start_at"
  end

  create_table "attendance_types", force: :cascade do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "school_id"
    t.boolean  "active",      default: true
    t.index ["school_id"], name: "index_attendance_types_on_school_id"
  end

  create_table "attendances", force: :cascade do |t|
    t.integer  "school_id"
    t.integer  "section_id"
    t.integer  "user_id"
    t.date     "attendance_date"
    t.integer  "excuse_id"
    t.integer  "attendance_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "comment",            default: ""
    t.index ["attendance_type_id"], name: "index_attendances_on_attendance_type_id"
    t.index ["excuse_id"], name: "index_attendances_on_excuse_id"
    t.index ["school_id"], name: "index_attendances_on_school_id"
    t.index ["section_id"], name: "index_attendances_on_section_id"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "disciplines", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_disciplines_on_name"
  end

  create_table "enrollments", force: :cascade do |t|
    t.integer  "student_id"
    t.integer  "section_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "student_grade_level"
    t.boolean  "active",              default: true
    t.integer  "subsection",          default: 0,    null: false
    t.index ["active"], name: "index_enrollments_on_active"
    t.index ["section_id", "active", "student_id"], name: "enrollments_multi"
    t.index ["section_id", "active", "subsection"], name: "enrollments_multi2"
    t.index ["section_id", "active"], name: "enrollments_multi3"
    t.index ["section_id", "subsection"], name: "enrollments_multi4"
    t.index ["section_id"], name: "index_enrollments_on_section_id"
    t.index ["student_id"], name: "index_enrollments_on_student_id"
    t.index ["subsection"], name: "index_enrollments_on_subsection"
  end

  create_table "evidence_attachments", force: :cascade do |t|
    t.string   "name"
    t.integer  "evidence_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.index ["evidence_id"], name: "index_evidence_attachments_on_evidence_id"
  end

  create_table "evidence_hyperlinks", force: :cascade do |t|
    t.integer  "evidence_id"
    t.string   "title"
    t.string   "hyperlink"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["evidence_id"], name: "index_evidence_hyperlinks_on_evidence_id"
  end

  create_table "evidence_ratings", force: :cascade do |t|
    t.string   "rating"
    t.string   "comment"
    t.integer  "student_id"
    t.integer  "evidence_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["evidence_id"], name: "index_evidence_ratings_on_evidence_id"
    t.index ["student_id"], name: "index_evidence_ratings_on_student_id"
  end

  create_table "evidence_section_outcome_ratings", force: :cascade do |t|
    t.string   "rating"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "student_id"
    t.boolean  "flagged",                     default: false
    t.integer  "evidence_section_outcome_id"
    t.index ["evidence_section_outcome_id", "student_id"], name: "evidence_section_outcome_ratings_multi"
    t.index ["evidence_section_outcome_id"], name: "evidence_section_outcome_ratings_on_eso_id"
    t.index ["student_id"], name: "index_evidence_section_outcome_ratings_on_student_id"
  end

  create_table "evidence_section_outcomes", force: :cascade do |t|
    t.integer  "evidence_id"
    t.integer  "section_outcome_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.index ["evidence_id"], name: "index_evidence_section_outcomes_on_evidence_id"
    t.index ["position"], name: "index_evidence_section_outcomes_on_position"
    t.index ["section_outcome_id"], name: "index_evidence_section_outcomes_on_section_outcome_id"
  end

  create_table "evidence_template_subject_outcomes", force: :cascade do |t|
    t.integer  "evidence_template_id"
    t.integer  "subject_outcome_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["evidence_template_id"], name: "evidence_temp_subj_outc_on_temp_id"
    t.index ["subject_outcome_id"], name: "evidence_temp_subj_outc_on_out_id"
  end

  create_table "evidence_templates", force: :cascade do |t|
    t.integer  "subject_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["subject_id"], name: "index_evidence_templates_on_subject_id"
  end

  create_table "evidence_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "evidences", force: :cascade do |t|
    t.string   "name"
    t.date     "assignment_date"
    t.integer  "position"
    t.integer  "section_outcome_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                     default: true
    t.integer  "evidence_type_id"
    t.string   "description"
    t.integer  "section_id"
    t.boolean  "reassessment",               default: false
    t.integer  "evidence_attachments_count", default: 0
    t.integer  "evidence_hyperlinks_count",  default: 0
    t.index ["active", "position"], name: "evidences_multi"
    t.index ["evidence_type_id"], name: "index_evidences_on_evidence_type_id"
    t.index ["section_id"], name: "index_evidences_on_section_id"
  end

  create_table "excuses", force: :cascade do |t|
    t.integer  "school_id"
    t.string   "code"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",      default: true
    t.index ["school_id"], name: "index_excuses_on_school_id"
  end

  create_table "posts", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "parent_id"
    t.string   "header"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "top_level_post_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.index ["parent_id"], name: "index_posts_on_parent_id"
    t.index ["top_level_post_id"], name: "index_posts_on_top_level_post_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "researchers", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "school_years", force: :cascade do |t|
    t.string   "name"
    t.integer  "school_id"
    t.date     "starts_at"
    t.date     "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["school_id"], name: "index_school_years_on_school_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string   "name"
    t.string   "acronym"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.integer  "marking_periods"
    t.boolean  "subsection",        default: false
    t.string   "grading_algorithm"
    t.string   "grading_scale"
    t.integer  "school_year_id"
    t.string   "flags"
    t.integer  "min_grade"
    t.integer  "max_grade"
    t.index ["school_year_id"], name: "index_schools_on_school_year_id"
  end

  create_table "section_attachments", force: :cascade do |t|
    t.integer  "section_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.index ["section_id"], name: "index_section_attachments_on_section_id"
  end

  create_table "section_outcome_attachments", force: :cascade do |t|
    t.string   "name"
    t.integer  "section_outcome_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.index ["section_outcome_id"], name: "index_section_outcome_attachments_on_section_outcome_id"
  end

  create_table "section_outcome_ratings", force: :cascade do |t|
    t.string   "rating"
    t.integer  "student_id"
    t.integer  "section_outcome_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["section_outcome_id"], name: "index_section_outcome_ratings_on_section_outcome_id"
    t.index ["student_id", "section_outcome_id"], name: "section_outcome_ratings_multi"
    t.index ["student_id"], name: "index_section_outcome_ratings_on_student_id"
  end

  create_table "section_outcomes", force: :cascade do |t|
    t.integer  "section_id"
    t.integer  "subject_outcome_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.integer  "marking_period"
    t.boolean  "active",             default: true
    t.boolean  "minimized",          default: false
    t.index ["active"], name: "index_section_outcomes_on_active"
    t.index ["position"], name: "index_section_outcomes_on_position"
    t.index ["section_id", "active", "position"], name: "section_outcomes_multi"
    t.index ["section_id"], name: "index_section_outcomes_on_section_id"
    t.index ["subject_outcome_id"], name: "index_section_outcomes_on_subject_outcome_id"
  end

  create_table "sections", force: :cascade do |t|
    t.string   "line_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "subject_id"
    t.text     "message"
    t.integer  "position"
    t.integer  "selected_marking_period"
    t.integer  "school_year_id"
    t.index ["school_year_id"], name: "index_sections_on_school_year_id"
    t.index ["subject_id"], name: "index_sections_on_subject_id"
  end

  create_table "server_configs", force: :cascade do |t|
    t.string   "district_id",         default: ""
    t.string   "district_name",       default: ""
    t.string   "support_email",       default: "trackersupport@21pstem.org"
    t.string   "support_team",        default: "Tracker Support Team"
    t.string   "school_support_team", default: "School IT Support Team"
    t.string   "server_url",          default: ""
    t.string   "server_name",         default: "Tracker System"
    t.string   "web_server_name",     default: "PARLO Tracker Web Server"
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.boolean  "allow_subject_mgr",   default: false
  end

  create_table "subject_outcomes", force: :cascade do |t|
    t.string   "description"
    t.integer  "position"
    t.integer  "subject_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "essential",          default: false
    t.integer  "marking_period"
    t.string   "lo_code",            default: ""
    t.boolean  "active",             default: true
    t.integer  "model_lo_id"
    t.integer  "curriculum_tree_id"
    t.index ["subject_id", "description"], name: "subject_outcomes_multi"
    t.index ["subject_id"], name: "index_subject_outcomes_on_subject_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string   "name"
    t.integer  "discipline_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "school_id"
    t.integer  "subject_manager_id"
    t.string   "bulk_lo_seq_year"
    t.datetime "bulk_lo_seq_timestamp"
    t.boolean  "active"
    t.index ["discipline_id"], name: "index_subjects_on_discipline_id"
    t.index ["school_id"], name: "index_subjects_on_school_id"
    t.index ["subject_manager_id"], name: "index_subjects_on_subject_manager_id"
  end

  create_table "system_administrators", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teaching_assignments", force: :cascade do |t|
    t.integer  "teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "section_id"
    t.boolean  "write_access", default: true
    t.index ["section_id"], name: "index_teaching_assignments_on_section_id"
    t.index ["teacher_id", "section_id"], name: "teaching_assignments_multi"
    t.index ["teacher_id"], name: "index_teaching_assignments_on_teacher_id"
  end

  create_table "teaching_resources", force: :cascade do |t|
    t.integer  "discipline_id"
    t.string   "title"
    t.string   "url"
    t.text     "description"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["discipline_id"], name: "index_teaching_resources_on_discipline_id"
    t.index ["title"], name: "index_teaching_resources_on_title"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "temporary_password"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "school_id"
    t.integer  "grade_level"
    t.string   "gender"
    t.boolean  "counselor"
    t.boolean  "school_administrator"
    t.boolean  "student"
    t.boolean  "system_administrator"
    t.boolean  "teacher"
    t.string   "xid"
    t.integer  "child_id",               default: 0
    t.boolean  "parent",                 default: false
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.string   "phone"
    t.integer  "absences"
    t.integer  "tardies"
    t.integer  "attendance_rate"
    t.boolean  "active",                 default: true
    t.string   "mastery_level"
    t.string   "subscription_status"
    t.boolean  "researcher",             default: false
    t.string   "race"
    t.boolean  "special_ed",             default: false
    t.string   "permissions"
    t.string   "duties"
    t.index ["active"], name: "index_users_on_active"
    t.index ["last_name", "first_name"], name: "index_users_on_last_name_and_first_name"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["school_id", "child_id"], name: "index_users_on_school_id_and_child_id"
    t.index ["school_id", "counselor"], name: "index_users_on_school_id_and_counselor"
    t.index ["school_id", "grade_level"], name: "index_users_on_school_id_and_grade_level"
    t.index ["school_id", "parent"], name: "index_users_on_school_id_and_parent"
    t.index ["school_id", "researcher"], name: "index_users_on_school_id_and_researcher"
    t.index ["school_id", "school_administrator"], name: "index_users_on_school_id_and_school_administrator"
    t.index ["school_id", "special_ed"], name: "index_users_on_school_id_and_special_ed"
    t.index ["school_id", "student"], name: "index_users_on_school_id_and_student"
    t.index ["school_id", "system_administrator"], name: "index_users_on_school_id_and_system_administrator"
    t.index ["school_id", "teacher"], name: "index_users_on_school_id_and_teacher"
    t.index ["school_id", "xid"], name: "index_users_on_school_id_and_xid"
    t.index ["school_id"], name: "index_users_on_school_id"
    t.index ["student", "active", "last_name", "first_name"], name: "student_alphabetical"
    t.index ["subscription_status"], name: "index_users_on_subscription_status"
    t.index ["teacher", "active", "last_name", "first_name"], name: "teacher_alphabetical"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
