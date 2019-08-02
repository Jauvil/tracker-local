Rails.application.routes.draw do
 # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  resources :announcements do
    member do
      get 'hide'
    end
  end

  resources :disciplines
  resources :evidence_types, except: [:destroy]
  resources :researchers
  devise_for :users

  match "users/bulk_update_staff" => "home#index", via: :get
  resources :users do
    get 'new_staff', on: :new, defaults: { format: :js } # new UI
    member do
      get 'change_password'
      get 'set_temporary_password' # to be deprecated - use set_user_temporary_password
      get 'security' # new UI
      get 'create_staff', defaults: { format: :js } # new UI
      get 'profile' # new UI
      get 'sections_list' # new UI
    end
    collection do
      get 'account_activity_report'
      get 'staff_listing'
      get 'bulk_upload_staff', defaults: {format: :html } # new ui
      post 'bulk_update_staff', defaults: {format: :html } # new ui
    end
  end

  resources :system_administrators, only: [:show] do
    get 'new_system_user', on: :new, defaults: { format: :js } # new UI
    member do
      get 'edit_system_user', defaults: { format: :js }
      patch 'update_system_user', defaults: { format: :js }
    end
    collection do
      post 'create_system_user', defaults: { format: :js }
      get 'system_maintenance'
      get 'system_users'
    end
  end

  resources :school_administrators

  match "schools/new_year_rollover" => "home#index", via: :get
  resources :schools do
    member do
      post 'new_year_rollover'
      get 'dashboard'
    end
  end
  # removed for Rails 3.2 to 4.0 initial conversion
  # match "schools/:id/edit(/:template)" => "schools#edit", via: [:get], as: "edit_school"

  # update to rails 4.1 security fixes
  # match "schools/:id/:report" => "schools#show", via: [:get, :post], as: "school_report"

  match "report_card" => "report_card#new", via: :get
  match "report_card" => "report_card#create", via: :post
  match "create_report_card" => "report_card#forward", via: :get
  # # failed attempt to remove above matches with standard resources statement
  # # - above work, below gets errors with missing :delete
  # # included index because otherwise it creates the following erroreous entry:
  # # report_card_index    POST   /report_card(.:format)   report_card#create
  # resources :report_card, except: [:show, :edit, :update] do
  #   member do
  #     get 'forward'
  #   end
  # end

  match "subjects/update_subject_outcomes" => "home#index", via: :get
  resources :subjects do
    member do
      get 'view_subject_outcomes', defaults: {format: :js} # new UI
      get 'edit_subject_outcomes'
      patch 'update_subject_outcomes'
    end
    collection do
      get 'list_editable_subjects'
      get 'proficiency_bars'
      get 'progress_meters'
    end
  end
  resources :teachers do
    collection do
      get 'tracker_usage'
    end
  end
  resources :counselors

  match "sections/update_bulk" => "home#index", via: :get
  match "sections/exp_col_all_evid" => "home#index", via: :get
  resources :sections, except: [:destroy] do
    member do
      get 'new_enrollment', defaults: { format: :js } # new UI
      get 'list_enrollments', defaults: { format: :js } # new UI
      get 'remove_enrollment' # new UI
      get 'new_evidence', defaults: { format: :html } # new UI
      get 'new_section_outcome', defaults: { format: :html } # new UI
      get 'section_outcomes'
      # get 'show_experimental'
      get 'restore_evidence', defaults: { format: :html } #new UI
      get 'section_summary_outcome', defaults: { format: :html } #new UI
      get 'section_summary_student', defaults: { format: :html } #new UI
      get 'nyp_student', defaults: { format: :html } #new UI
      get 'nyp_outcome', defaults: { format: :html } #new UI
      get 'student_info_handout', defaults: { format: :pdf } #new UI
      get 'progress_rpt_gen', defaults: { format: :html } #new UI
      get 'class_dashboard', defaults: { format: :html } #new UI
      put 'exp_col_all_evid', defaults: {format: :js} # new UI
      get 'edit_section_message', defaults: {format: :js} # new UI
      put 'update_section_message', defaults: {format: :js} # new UI
    end
    collection do
      get 'sort'
      get 'student_info_handout_by_grade', defaults: { format: :pdf } #new UI
      get 'enter_bulk', defaults: {format: :html } # new ui
      post 'update_bulk', defaults: {format: :html } # new ui
    end
  end


  match "students/bulk_update" => "home#index", via: :get
  resources :students do
    member do
      get 'set_student_temporary_password'
      get 'dashboard'
      get 'security'
      get 'sections_list' # new UI
    end
    collection do
      get 'bulk_upload', defaults: {format: :html } # new ui
      post 'bulk_update', defaults: {format: :html } # new ui
    end
  end

  # Proficiency Bars by Student report (students_report_path)
  #   is generated by students#index with the :report param set to 'proficiency_bar_chart'
  match "students/reports(/:report)" => "students#index", via: :get, as: "students_report"

  match "enrollments/update_bulk" => "home#index", via: :get
  resources :enrollments do
    collection do
      get 'enter_bulk', defaults: {format: :html } # new ui
      post 'update_bulk', defaults: {format: :html } # new ui
      get 'section_enrollments', defaults: {format: :js} # new ui
    end
  end

  resources :parents do
    member do
      get 'set_parent_temporary_password'
    end
  end

  match "subject_outcomes/lo_matching" => "home#index", via: :get
  match "subject_outcomes/lo_matching_update" => "home#index", via: :get
  resources :subject_outcomes, except: [:show, :destroy] do
    collection do
      get 'upload_lo_file'
      post 'upload_lo_file'
      post 'lo_matching'
      post 'lo_matching_update'
    end
  end

  match "section_outcomes/toggle_marking_period" => "home#index", via: :get
  resources :section_outcomes do
    member do
      get 'rate'
      get 'toggle_minimized'
      get 'evidences_left'
      get 'evidences_right'
      put 'toggle_marking_period', defaults: {format: :js} # new UI
    end
    collection do
      get 'sort'
    end
  end
  resources :evidence_section_outcome_ratings, only: [:show, :create, :update], path: 'e_s_o_r'
  resources :evidence_section_outcomes do
    collection do
      get 'sort'
    end
  end
  resources :evidences do
    member do
      get 'rate' # new UI
      # get 'restore'
      get 'toggle_minimized'
      get 'show_attachments'
    end
    collection do
      get 'sort'
    end
  end
  resources :section_attachments
  resources :section_outcome_attachments
  resources :section_outcome_ratings, except: :destroy
  resources :evidence_attachments
  resources :posts

  resources :teaching_assignments, only: [] do
    collection do
      get 'enter_bulk'
      post 'update_bulk'
    end
  end

  resources :teaching_resources
  root :to => "home#index"

  get 'upload_bulk_templates', to: 'misc#upload_bulk_templates'
  resources :excuses, except: [:show, :destroy]
  resources :attendance_types, except: [:show, :destroy]

  match "attendances/section_attendance_update" => "home#index", via: :get
  resources :attendances do
    member do
      get 'section_attendance'
    end
    collection do
      # get 'section_attendance'
      get 'section_attendance_by_date'
      post 'section_attendance_update'
      get 'section_attendance_xls', defaults: {format: :xlsx}
      get 'attendance_maintenance'
      get 'attendance_report'
      get 'student_attendance_detail_report'
    end
  end
  resources :generates, except: [:show, :update, :destroy]

  resources :server_configs, only: [:show, :edit, :update]

  resources :ui, only: [] do
    collection do
      put 'save_cell_size'
      put 'save_toolkit'
    end
  end

  # any unmatched posts go to home page.
  match "*path" => "home#index", via: [:post]

  # must be last item
  # match ':action' => 'static#:action'
  match ':action' => 'misc#:action', :via => [:get]

end
