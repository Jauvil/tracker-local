// This is a manifest file that'll be compiled into application.js,
//   which will include all the files listed below.
//
// Place your application-specific JavaScript functions and classes here
//   This file is automatically included by javascript_include_tag :defaults
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts,
//   vendor/assets/javascripts, or vendor/assets/javascripts of plugins,
//   if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do,
//   it'll appear at the bottom of the compiled file.
//
// Read Sprockets README
//   (https://github.com/rails/sprockets#sprockets-directives)
//   for details about supported directives.
//

// use modernizr from proui (to provide touch/no-touch detection)
//= require proui-v2.0/vendor/modernizr-2.7.1-respond-1.4.2.min

// use jquery version to match proui plugins
//= require jquery-1.11.1/jquery-1.11.1

// ujs from rails
//= require jquery_ujs

//= require bootstrap-v3.1.1/bootstrap

// note: these plugins match jquery-1.11.1 - e.g. jquery ui 1.10.4
//= require proui-v2.0/plugins
//= require proui-v2.0/app

// application specific javascript
//= require tracker_app
//= require tracker_page
//= require trackerCommonCode
//= require all_pages
//= require add_edit_evidence_page
//= require edit_subject_outcomes_page
//= require generate_reports_page
//= require student_tracker_page
//= require misc_page
//= require bulk_enroll_students_page
