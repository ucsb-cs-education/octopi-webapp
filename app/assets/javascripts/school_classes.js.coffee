# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

SchoolClassesController = Paloma.controller('SchoolClasses');

SchoolClassesController.prototype.show = () ->
  SortableJS()

SchoolClassesController.prototype.edit = () ->
  showFormAndHideAddNewStudentButton = () ->
    $("#new_student").removeClass("hidden")
    $("#new_student_button").addClass("hidden")

  hideFormAndShowNewStudentButton = () ->
    $("#new_student").addClass("hidden")
    $("#new_student_button").removeClass("hidden")

  addButtonOnClicks = () ->
    $("#new_student_button").click(showFormAndHideAddNewStudentButton)
    $("#cancel_new_student_button").click(hideFormAndShowNewStudentButton)

  SortableJS()

  $(document).ready(addButtonOnClicks);
  $(document).ready()

  $("#student_csv_csv").change ->
    unless $(this).val() is ""
      $("#student-csv-submit").attr "disabled", false
    else
      $("#student-csv-submit").attr "disabled", true
    return

SchoolClassesController.prototype.edit_students_via_csv = () ->
  check_all_problems_resolved = ->
    form = $("#actions-form form")
    if form.children(".action-problem-div").not(".exclude").length is 0
      $("#continue-btn").attr "disabled", false
    else
      $("#continue-btn").attr "disabled", true

  $(".conflict-checkbox").change ->
    if $(this).prop("checked")
      $(this).removeClass "conflicting"
      $(this).parent().removeClass("action-problem-div").addClass "action-success-div"  if $(this).parent().children(".conflicting").length is 0
    else
      $(this).addClass "conflicting"
      $(this).parent().removeClass("action-success-div").addClass "action-problem-div"

  $(".conflict-textbox").keyup ->
    if $(this).val() is $(this).attr("data-correct")
      $(this).removeClass "conflicting"
      if $(this).parent().children(".conflicting").length is 0
        $(this).parent().removeClass("action-problem-div").addClass "action-success-div"
        check_all_problems_resolved()
    else
      $(this).addClass "conflicting"
      $(this).parent().removeClass("action-success-div").addClass "action-problem-div"
      check_all_problems_resolved()

  $(".do-this-box").change ->
    if $(this).prop("checked")
      $(this).parent().parent().removeClass "exclude"
    else
      $(this).parent().parent().addClass "exclude"

  $(document).change ->
    check_all_problems_resolved()

  check_all_problems_resolved()
  $("#actions-form form").submit ->
    $("#actions-form form").children(".exclude").children(".form-group").remove()


SchoolClassesActivitiesController = Paloma.controller('SchoolClasses/SchoolClassesActivities')
SchoolClassesActivitiesController.prototype.activity_page = () ->
  $(document).on "click", ".unlock-all", ->
    confirm("This will unlock for all students in this class and cannot be easily undone.\nDo you wish to continue?")

  new Grid("progress-table-div",
    srcType: "dom"
    srcData: "tasks-table"
    allowGridResize: false
    allowColumnResize: false
    allowClientSideSorting: true
    colSortType: [
      "string"
      "string"
      "number"
    ]
    allowSelections: true
    allowMultipleSelections: false
    showSelectionColumn: false
    fixedCols: 2
  )

SchoolClassesActivitiesController.prototype.reset_page = () ->
  new Grid("progress-table-div",
    srcType: "dom"
    srcData: "tasks-table"
    allowGridResize: false
    allowColumnResize: false
    allowClientSideSorting: true
    colSortType: [
      "string"
      "string"
      "number"
    ]
    allowSelections: true
    allowMultipleSelections: false
    showSelectionColumn: false
    fixedCols: 2
  )

  $(".reset-single-response").submit ->
    confirm("This will delete  the student's current response and reset their progress to not begun. This cannot be undone.\n Continue?")

  $(".reset-task-form").submit (e) ->
    currentForm = this
    prompt = "This will delete all files students have for this task. Any tasks that students have begun or completed will be reset to not begun."
    email = $(currentForm).find("input[type=submit]").attr("data-email")
    errorMessage = "You must enter your email to continue, or press cancel to quit."
    e.preventDefault()
    confirmationPrompt prompt, email, {success: ->
      currentForm.submit()
    }, errorMessage

  $(".reset-activity-form").submit (e) ->
    currentForm = this
    prompt = "This will delete ALL files students have for this activity. Any tasks that students have begun or completed will be reset to not begun."
    email = $(currentForm).find("input[type=submit]").attr("data-email")
    errorMessage = "You must enter your email to continue, or press cancel to quit."
    e.preventDefault()
    confirmationPrompt prompt, email, {success: ->
      currentForm.submit()
    }, errorMessage


SchoolClassesStudentProgressController = Paloma.controller('SchoolClasses/SchoolClassesStudentProgress')
SchoolClassesStudentProgressController.prototype.student_progress = () ->
  $(document).on "click", ".student_progress", ->
    confirm("This will reset the student's progress to where it currently should be based on what they have completed.
        Tasks and Activities that were manually unlocked for them and they have not completed or completed the prerequisites of will be locked again.\nContinue?")
