# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

TeacherPortalController = Paloma.controller('TeacherPortal');


TeacherPortalController.prototype.edit_class = () ->
  showFormAndHideAddNewStudentButton = () ->
    $("#new_student").removeClass("hidden")
    $("#new_student_button").addClass("hidden")

  hideFormAndShowNewStudentButton = () ->
    $("#new_student").addClass("hidden")
    $("#new_student_button").removeClass("hidden")

  addButtonOnClicks = () ->
    $("#new_student_button").click(showFormAndHideAddNewStudentButton)
    $("#cancel_new_student_button").click(hideFormAndShowNewStudentButton)


  $(document).ready(addButtonOnClicks);
  $(document).ready()

  $("#student_csv_csv").change ->
    unless $(this).val() is ""
      $("#student-csv-submit").attr "disabled", false
    else
      $("#student-csv-submit").attr "disabled", true
    return

