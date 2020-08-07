errors_count = <%= @student.errors.count %>
if errors_count.toString() != '0'
  console.log('we have an error');
  # display flash messages if any
  $('#breadcrumb-flash-msgs').html("<%= escape_javascript(render('layouts/messages')) %>")
  $('#modal-message').html("<%= escape_javascript(render('layouts/messages')) %>")
  # redisplay form with errors
  # $('#modal_content').html("<%= escape_javascript(render('students/create') ) %>");
  $('#modal-body').html("<%= escape_javascript(render('students/create') ) %>");
else
  # display flash messages if any
  $('#breadcrumb-flash-msgs').html("<%= escape_javascript(render('layouts/messages')) %>")
  # close out dialog if it exists
  console.log 'closing out dialog box'
  $('#modal_popup').modal('hide')

  # if successful, refresh listing
  # todo add spinner here
  window.location.href = "<% students_path %>"