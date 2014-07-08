# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

PagesController = Paloma.controller('SchoolClasses');

PagesController.prototype.edit = () ->

  showFormAndHideAddNewStudentButton = () ->
    $("#create_and_add_student_form").toggle()
    $("#toggle_add_new_student_button").toggle()
    $("#cancel_button").toggle()
    return

  hideFormAndShowNewStudentButton = () ->
    $("#create_and_add_student_form").toggle()
    $("#toggle_add_new_student_button").toggle()
    $("#cancel_button").toggle()
    return

  addButtonOnClicks = () ->
    $("#toggle_add_new_student_button").onclick(showFormAndHideAddNewStudentButton)
    $("#cancel_button").onclick(hideFormAndShowNewStudentButton)

  $(document).ready(addButtonOnClicks);
  $(document).ready()
