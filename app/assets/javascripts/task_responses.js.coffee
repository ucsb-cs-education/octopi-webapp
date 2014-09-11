TaskResponsesController = Paloma.controller('TaskResponses');

TaskResponsesController.prototype.show = () ->
  $("#change-student").change ->
    $(this).attr "action", $("#change-student option:selected").val()

TaskResponsesController.prototype.index = () ->
  SortableJS()
  $("#no-data-yet-div form").submit ->
    msg = "The data is now being collected and prepared. This may take up to several minutes," + " depending on how many student responses there are. Come back or refresh the page later to see the results."
    msg += "You will know it is completed when the date the page was last updated at changes."  if $("#time-div").length
    bootbox.alert msg