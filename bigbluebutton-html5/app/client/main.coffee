# Helper to load javascript libraries from the BBB server
loadLib = (libname) ->
  successCallback = ->

  retryMessageCallback = (param) ->
    #Meteor.log.info "Failed to load library", param
    console.log "Failed to load library", param

  Meteor.Loader.loadJs("http://#{window.location.hostname}/client/lib/#{libname}", successCallback, 10000).fail(retryMessageCallback)

# These settings can just be stored locally in session, created at start up
Meteor.startup ->
  # Load SIP libraries before the application starts
  loadLib('sip.js')
  loadLib('bbb_webrtc_bridge_sip.js')
  loadLib('bbblogger.js')

  @SessionAmplify = _.extend({}, Session,
    keys: _.object(_.map(amplify.store(), (value, key) ->
      [
        key
        JSON.stringify(value)
      ]
    ))
    set: (key, value) ->
      Session.set.apply this, arguments
      amplify.store key, value
      return
  )
#
Template.header.events
  "click .chatBarIcon": (event) ->
    $(".tooltip").hide()
    toggleChatbar()

  "click .hideNavbarIcon": (event) ->
    $(".tooltip").hide()
    toggleNavbar()

  "click .leaveAudioButton": (event) ->
    exitVoiceCall event

  "click .muteIcon": (event) ->
    $(".tooltip").hide()
    toggleMic @

  "click .lowerHand": (event) ->
    $(".tooltip").hide()
    BBB.lowerHand(BBB.getMeetingId(), getInSession("userId"), getInSession("userId"), getInSession("authToken"))

  "click .raiseHand": (event) ->
    $(".tooltip").hide()
    BBB.raiseHand(BBB.getMeetingId(), getInSession("userId"), getInSession("userId"), getInSession("authToken"))

  "click .settingsIcon": (event) ->
    setInSession("tempFontSize", getInSession("messageFontSize"))
    $("#settingsModal").foundation('reveal', 'open');

  "click .signOutIcon": (event) ->
    $('.signOutIcon').blur()
    $("#logoutModal").foundation('reveal', 'open');

  "click .hideNavbarIcon": (event) ->
    $(".tooltip").hide()
    toggleNavbar()

  "click .usersListIcon": (event) ->
    $(".tooltip").hide()
    toggleUsersList()

  "click .videoFeedIcon": (event) ->
    $(".tooltip").hide()
    toggleCam @

  "click .toggleUserlist": (event) ->
    toggleUsersList()

  "click .toggleMenuButton": (event) ->
    toggleRightHandSlidingMenu()

Template.menu.events
  'click .slideButton': (event) ->
    toggleRightHandSlidingMenu()

Template.main.rendered = ->
  $("#dialog").dialog(
    modal: true
    draggable: false
    resizable: false
    autoOpen: false
    dialogClass: 'no-close logout-dialog'
    buttons: [
      {
        text: 'Yes'
        click: () ->
          userLogout BBB.getMeetingId(), getInSession("userId"), true
          $(this).dialog("close")
        class: 'btn btn-xs btn-primary active'
      }
      {
        text: 'No'
        click: () ->
          $(this).dialog("close")
          $(".tooltip").hide()
        class: 'btn btn-xs btn-default'
      }
    ]
    open: (event, ui) ->
      $('.ui-widget-overlay').bind 'click', () ->
        if isMobile()
          $("#dialog").dialog('close')
    position:
      my: 'right top'
      at: 'right bottom'
      of: '.signOutIcon'
  )

  Meteor.NotificationControl = new NotificationControl('notificationArea')
  $(document).foundation() # initialize foundation javascript

  $(window).resize( ->
    $('#dialog').dialog('close')
  )

  $('#shield').click () ->
    toggleSlidingMenu()

  if Meteor.config.app.autoJoinAudio
    onAudioJoinHelper()

Template.makeButton.rendered = ->
  $('button[rel=tooltip]').tooltip()
