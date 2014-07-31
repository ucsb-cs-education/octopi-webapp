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

SchoolClassesActivitiesController = Paloma.controller('SchoolClasses/SchoolClassesActivities')
SchoolClassesActivitiesController.prototype.activity_page = () ->
  $(".unlock-all").click ->
    confirm "This will unlock the task for all students and cannot be undone.\nDo you wish to continue?"

  $(document).on "click", ".charts-tooltip", ->
    id = $(this).find("div").text()
    $("#progress-table-div").scrollLeft 0
    $("#progress-table-div").scrollLeft $(document.getElementById(id)).offset().left - $("#progress-table-div").offset().left
    return

  $(document).on "click", "text[text-anchor=\"middle\"]", ->
    id = $(this).text()
    $("#progress-table-div").scrollLeft 0
    $("#progress-table-div").scrollLeft $(document.getElementById(id)).offset().left - $("#progress-table-div").offset().left
    return

  $("#name-header").wrapInner("<span title=\"Click to sort\"/>").each ->
    th = $(this)
    thIndex = th.index()
    inverse = false
    th.click ->
      $("#tasks-table").find("td").not(".button-td").filter(->
        $(this).index() is thIndex
      ).sortElements ((a, b) ->
        (if $.text([a]) > $.text([b]) then (if inverse then -1 else 1) else (if inverse then 1 else -1))  unless @parentNode is $("#button-tr")
      ), ->
        @parentNode

      inverse = not inverse
      return

    return

  $("#progress-header").wrapInner("<span title=\"Click to sort\"\"/>").each ->
    th = $(this)
    thIndex = th.index()
    inverse = false
    th.click ->
      $("#tasks-table").find("td").not(".button-td").filter(->
        $(this).index() is thIndex
      ).sortElements ((a, b) ->
        (if (parseInt($.text([a]))+1 || -1) > (parseInt($.text([b]))+1 || -1) then (if inverse then -1 else 1) else (if inverse then 1 else -1))  unless @parentNode is $("#button-tr")
      ), ->
        @parentNode

      inverse = not inverse
      return

    return


