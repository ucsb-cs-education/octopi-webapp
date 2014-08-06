#= require ckeditor/init
#= require ckeditor/config
#= require ckeditor/plugins/openlink/plugin
#= require ckeditor/plugins/openlink/lang/en
#= require ckeditor/basepath

$(document).ready(() ->
  $('form[data-remote]').bind('ajax:before', () ->
    for key of CKEDITOR.instances
      CKEDITOR.instances[key].updateElement()
  )
)
