# See  http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.config.html#.toolbar_Full for all options
CKEDITOR.editorConfig = (config) ->
  config.language = 'en'
  config.toolbar_Pure = [
    { name: 'clipboard', items: [ 'Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo' ] },
    { name: 'editing', items: [ 'Find', 'Replace', '-', 'SelectAll', '-', 'SpellChecker', 'Scayt' ] },
    { name: 'links', items: [ 'Link', 'Unlink', 'Anchor' ] },
    { name: 'insert', items: [ 'Image', 'Youtube', 'Table', 'HorizontalRule', 'Smiley', 'SpecialChar', 'PageBreak' ] },
    { name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-',
                                    'RemoveFormat' ] },
    '/',
    { name: 'styles', items: [ 'Styles', 'Format', 'Font', 'FontSize' ] },
    { name: 'paragraph', groups: [ 'list', 'indent', 'blocks', 'align', 'bidi' ], items: [ 'NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-',
               'Blockquote', 'CreateDiv', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock' ] },
    { name: 'document' , items: [ 'Sourcedialog', '-', 'Maximize', 'Preview', 'ShowBlocks'] }
  ]
  config.toolbar = 'Pure'
  config.extraPlugins = 'openlink,sourcedialog,youtube,preview'
  config.font_names = (CKEDITOR.config.font_names + ";Century Gothic/Century Gothic").split(';').sort().join(';');


  #The following options are frm ckeditor-4.1/app/assetes/javascripts/ckeditor
  # Define changes to default configuration here. For example:
  # config.language = 'fr';
  # config.uiColor = '#AADC6E';

  config.youtube_width = '640';
  config.youtube_height = '480';
  config.youtube_related = false;
  config.youtube_older= false;
  config.youtube_privacy = false;

  config.extraAllowedContent = 'video[*]{*};source[*]{*}'


  # Filebrowser routes
  # The location of an external file browser, that should be launched when "Browse Server" button is pressed.
  config.filebrowserBrowseUrl = "/ckeditor/attachment_files"

  # The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Flash dialog.
  config.filebrowserFlashBrowseUrl = "/ckeditor/attachment_files"

  # The location of a script that handles file uploads in the Flash dialog.
  config.filebrowserFlashUploadUrl = "/ckeditor/attachment_files"

  # The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Link tab of Image dialog.
  config.filebrowserImageBrowseLinkUrl = "/ckeditor/pictures"

  # The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Image dialog.
  config.filebrowserImageBrowseUrl = "/ckeditor/pictures"

  # The location of a script that handles file uploads in the Image dialog.
  config.filebrowserImageUploadUrl = "/ckeditor/pictures"

  # The location of a script that handles file uploads.
  config.filebrowserUploadUrl = "/ckeditor/attachment_files"

  # Rails CSRF token
  config.filebrowserParams = ->
    csrf_token = undefined
    csrf_param = undefined
    meta = undefined
    metas = document.getElementsByTagName("meta")
    params = {}
    i = 0

    while i < metas.length
      meta = metas[i]
      switch meta.name
        when "csrf-token"
          csrf_token = meta.content
        when "csrf-param"
          csrf_param = meta.content
        else
      i++
    params[csrf_param] = csrf_token  if csrf_param isnt `undefined` and csrf_token isnt `undefined`
    params

  config.addQueryString = (url, params) ->
    queryString = []
    unless params
      return url
    else
      for i of params
        queryString.push(i + "=" + encodeURIComponent(params[i]))
    url + ((if (url.indexOf("?") isnt -1) then "&" else "?")) + queryString.join("&")


  # Integrate Rails CSRF token into file upload dialogs (link, image, attachment and flash)
  CKEDITOR.on "dialogDefinition", (ev) ->

    # Take the dialog name and its definition from the event data.
    dialogName = ev.data.name
    dialogDefinition = ev.data.definition
    content = undefined
    upload = undefined
    if CKEDITOR.tools.indexOf([
      "link"
      "image"
      "attachment"
      "flash"
    ], dialogName) > -1
      content = (dialogDefinition.getContents("Upload") or dialogDefinition.getContents("upload"))
      upload = ((if content is null then null else content.get("upload")))
      if upload and upload.filebrowser and upload.filebrowser["params"] is `undefined`
        upload.filebrowser["params"] = config.filebrowserParams()
        upload.action = config.addQueryString(upload.action, upload.filebrowser["params"])


