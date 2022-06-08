rapidjson = require "rapidjson"

zoomRoom = Ssh.New()
zoomRoom.ReconnectTimeout = 1
zoomRoom.ReadTimeout = 5

queue_timer, poll_timer = Timer.New(), Timer.New()
micMuteTimer, camMuteTimer = Timer.New(), Timer.New()
participantBypassTimer = Timer.New()
PresenceUpdateTimers = {Timer.New(), Timer.New()}

myId = nil
pollRate, commandRate = 1, .01
micMuteBypass, camMuteBypass = false, false
updateParticipantBypass = false
phonebookReceived = false
hangingUp = false
choices = {}

Text_Indicators = {
  "Meeting ID",
  "Room Name",
  "Call Status",
  "Join Meeting ID",
  "Join Meeting Password",
  "Sharing Status",
  "Sharing Display State",
  "Presentation Pairing Code",
  "Presentation Sharing Key",
  "Caller Name",
  "Camera Lines",
  "Sharing WiFi Name",
  "Sharing Server Name",
  "Sharing Password",
  "Meeting Password",
  --"Host Key",
  "Number of Screens",
  "Room PMI",
  "Room Version",
  "Camera Sharing Name",
  "App Version",
  "Spotlight Status",
  "Number of Zoom Rooms",
  "Number of Normal Contacts",
  "Number of Legacy Rooms",
  "Total Contacts"
}

LED_Indicators = {
  "In Call",
  "Incoming Call",
  "Is Airplay Sharing",
  "Is Black Magic Connected",
  "Is Black Magic Data Available",
  "Is Black Magic Sharing",
  "Is Direct Presentation Connected",
  "Sharing Paused",
  "Meeting Needs Password",
  "Waiting for Host",
  --"Is Auto Answer Enabled",
  "Is Closed Caption Available",
  "Is Airhost Disabled",
  "Supports Pin and Spotlight",
  "Supports Expel User Permanently"
}

In_Call_Toggles = {
  "Mute Mic",
  "Mute Video",
  "Camera Mirror",
  "Mute Participant Mic",
  "Mute Participant Video"
}

In_Call_LEDs = {
  "Is Video Optimizable",
  "Sharing Instructions Visible",
  "Call Locked",
  "Mute User on Entry",
  "Camera is Sharing",
  "Camera Sharing Can Control",
  "Am I Recording",
  "Can Record",
  "Meeting is Being Recorded",
  "Email Required",
  "Spotlight Active",
  "Participant Can Record",
  "Participant is Recording",
  "In Waiting Room"
  --"Participant is Audio Muted",
  --"Participant is Video Muted"
}

Zoom_Responses = {

  Audio = function(Audio)
        
    if ((Audio.Input) and (Audio.Input.selectedId)) then BuildAudioInputChoices(Audio.Input.selectedId) end
    
    if ((Audio.Output) and (Audio.Output.selectedId)) then BuildAudioOutputChoices(Audio.Output.selectedId) end
  
  end,
  
  AudioInputLine = function(AudioInputLine)
    
    audioInputConfigurationReceived = true
    
    audio_input_lines = {}
    
    for i, tbl in pairs(AudioInputLine) do
      audio_input_lines[tbl.id] = {}
      audio_input_lines[tbl.id]['name'] = tbl.Name
      audio_input_lines[tbl.id]['alias'] = tbl.Alias
    end
    
    Enqueue("zConfiguration Audio Input SelectedId")
  
  end,
  
  AudioOutputLine = function(AudioOutputLine)
    
    audioOutputConfigurationReceived = true
    
    audio_output_lines = {}
    
    for i, tbl in pairs(AudioOutputLine) do
      audio_output_lines[tbl.id] = {}
      audio_output_lines[tbl.id]['name'] = tbl.Name
      audio_output_lines[tbl.id]['alias'] = tbl.Alias
    end
    
    Enqueue("zConfiguration Audio Output SelectedId")
    
  end,
  
  BookingsListResult = function(BookingsListResult)
      
    print(string.format("%d Bookings Found", #BookingsListResult))
    
    booking_list = {}
    
    for i, tbl in pairs(BookingsListResult) do
      if not tbl.isInstantMeeting then
        booking_list[tbl.meetingNumber] = {}
        booking_list[tbl.meetingNumber]['name'] = tbl['meetingName']
        booking_list[tbl.meetingNumber]['start'] = tbl['startTime']
        booking_list[tbl.meetingNumber]['end'] = tbl['endTime']
        booking_list[tbl.meetingNumber]['creator'] = tbl['creatorEmail']
      end
    end
    
    BuildBookingChoices(booking_list)
        
  end,
  
  BookingsUpdated = function(BookingsUpdated)
      
    print("Fetching Bookings List...")
    
    Enqueue("zCommand Bookings List")
    
  end,
  
  BookingsUpdateResult = function(BookingsUpdateResult)
    
  end,
  
  Call = function(Call)
      
    if (Call.Status) then
      
      global_status = Call.Status
      local status = ""
      
      -- if not in a meeting, reset 'in call' controls/indicators
      if (Call.Status == "NOT_IN_MEETING") then
        
        Timer.CallAfter(function() hangingUp = false end, (pollRate+0.01))
        Controls["Call Status"].String = "Not in Meeting"
        ResetInCallControls()
        ResetParticipantsList()
        Controls["Meeting ID"].String = ""
        Controls["Meeting Password"].String = ""
        inCall = false
        SetLED("In Call", false)
        SetLED("In Call Presentation", false)
        participantsReceived = false
        
      elseif (Call.Status == "CONNECTING_MEETING") then
        
        inCall = false
        Controls["Call Status"].String = "Connecting Meeting..."
        SetLED("In Call", false)
        SetLED("In Call Presentation", false)
        participantsReceived = false
        
      elseif (Call.Status == "IN_MEETING") then
        
        inCall = true
        Enqueue("zCommand Call Info", 1)
        if (not participantsReceived) then Enqueue("zCommand Call ListParticipants") end
        
      end
      
      if (not phonebookIsFetching) then SetStatus(0, status) end
    
    elseif (Call.ClosedCaption) then
    
      if (Call.ClosedCaption.Available ~= nil) then SetLED("Is Closed Caption Available", Call.ClosedCaption.Available) end
      
      if (Call.ClosedCaption.Visible ~= nil) then Controls["Closed Caption Visible"].Boolean = Call.ClosedCaption.Visible end
      
      if (Call.ClosedCaption.FontSize) then --[[print(Call.ClosedCaption.FontSize)]] end
      
    elseif (Call.Layout) then
      
      if (Call.Layout.Size) then --[[print(Call.Layout.Size)]] end
      
      if (Call.Layout.Position) then --[[print(Call.Layout.Position)]] end
    
    elseif (Call.Share) then
    
      if (Call.Share.Setting) then --[[print(Call.Share.Setting)]] end
    
    elseif (Call.Lock) then
    
      if (Call.Lock.Enable ~= nil) then SetLED("Call Locked", Call.Lock.Enable) end
    
    elseif (Call.MuteUserOnEntry) then
    
      if (Call.MuteUserOnEntry.Enable  ~= nil) then SetLED("Mute User on Entry", Call.MuteUserOnEntry.Enable) end
    
    elseif (Call.Camera) then
    
      if ((Call.Camera.Mute ~= nil) and (not camMuteBypass)) then Controls["Mute Video"].Boolean = Call.Camera.Mute end
    
    elseif (Call.Microphone) then
    
      if ((Call.Microphone.Mute ~= nil) and (not micMuteBypass)) then Controls["Mute Mic"].Boolean = Call.Microphone.Mute end
    
    end
    
  end,
  
  CallConnect = function(CallConnect)
    if CallConnect.success == "on" then
      Controls["Call Connect Trigger"]:Trigger()
      print("Call Connected - Firing 'Call Connected' Trigger")
    end
  end,

  CallConnectError = function(CallConnectError)
    if CallConnectError.error_message == "Participant screen sharing was disabled" then
      Controls["Screen Sharing Disabled"]:Trigger()
      print("Unable to Share Screen - Firing 'Sharing Disabled' Trigger")
    end
  end,
  
  CallDisconnect = function(CallDisconnect)
    if CallDisconnect.success == "on" then
      callWasAutoAnswered = false
      SetLED("In Call", false)
      SetLED("In Call Presentation", false)
      Controls["Call Disconnect Trigger"]:Trigger()
      print("Call Disconnected - Firing 'Call Disconnected' Trigger")
    end
  end,
  
  CallEnded = function(CallEnded)

    if (Controls['Call Ended by Host Mode'].String == "Always Trigger") then
      Controls["Call Ended by Host Trigger"]:Trigger()
      print("Host Ended Call - Firing 'Call Ended by Host' Trigger")
    elseif (Controls['Call Ended by Host Mode'].String == "Auto-Answered Calls Only") and callWasAutoAnswered then
      Controls["Call Ended by Host Trigger"]:Trigger()
      print("Host Ended Call (Auto-Answered) - Firing 'Call Ended by Host' Trigger")
    end
    
  end,
  
  CameraShare = function(CameraShare)
  
    if (CameraShare.id ~= "") then
      for id, tbl in pairs(camera_lines) do
        if id == CameraShare.id then Controls["Camera Sharing Name"].String = tbl.name end
      end
    else
      Controls["Camera Sharing Name"].String = "None"
    end
    
    SetLED("Camera is Sharing", CameraShare.is_Sharing)
    SetLED("Camera Sharing Can Control", CameraShare.can_Control_Camera)
        
  end,
  
  Capabilities = function(Capabilities)
  
    SetLED("Is Airhost Disabled", Capabilities.is_Airhost_Disabled)
    SetLED("Supports Pin and Spotlight", Capabilities.support_Pin_And_Spotlight)
    SetLED("Supports Expel User Permanently", Capabilities.supports_Expel_User_Permanently)

  end,
  
  Client = function(Client)
  
    if (Client.appVersion) then Controls["App Version"].String = Client.appVersion end
  
  end,
  
  IncomingCallIndication = function(IncomingCallIndication)
        
    Controls["Caller Name"].String = IncomingCallIndication.callerName
    
    callerJID = IncomingCallIndication.callerJID
    
    SetLED("Incoming Call", true)
    
    if (Controls["Auto Answer"].Boolean) and not (Controls['In Call'].Boolean) then
      callWasAutoAnswered = true
      canHangup = false
      Timer.CallAfter(function() canHangup = true; end, 10)
      print("Bypassing 'Force Hangup' for [10] Seconds")
      Controls["Auto Answered Trigger"]:Trigger()
      CallAccept()
      print("Auto Answering the Incoming Call.")
    end
    
  end,
  
  InfoResult = function(InfoResult)

    local id = InfoResult.meeting_id
    
    Controls["Meeting ID"].String = string.format("%s %s %s", id:sub(1, 3), id:sub(4, 7), id:sub(8))
    
    Controls["Meeting Password"].String = InfoResult.meeting_password

    SetLED("In Call Presentation", (InfoResult.meeting_type == "SHARING_LAPTOP"))
    SetLED("In Call", (InfoResult.meeting_type == "SHARING_LAPTOP") or (InfoResult.meeting_type == "NORMAL"))
    Controls['Call Status'].String = (InfoResult.meeting_type == "SHARING_LAPTOP") and "In Presentation Mode" or (InfoResult.meeting_type == "NORMAL") and "In Meeting"
    SetLED("In Waiting Room", (InfoResult.is_waiting_room))
    print(string.format("Call Status: Is Waiting Room [%s], Meeting Type [%s]", InfoResult.is_waiting_room, InfoResult.meeting_type))
      
  end,
  
  Layout = function(Layout)
      
    choices['views'] = {}
    
    if Layout.can_Switch_Speaker_View then table.insert(choices.views, {Text = "Speaker", Color = "Black"}) end
    if Layout.can_Switch_Strip_View then table.insert(choices.views, {Text = "Strip", Color = "Black"}) end
    if Layout.can_Switch_Wall_View then table.insert(choices.views, {Text = "Gallery", Color = "Black"}) end
    if Layout.can_Switch_Share_On_All_Screens then table.insert(choices.views, {Text = "ShareAll", Color = "Black"}) end
    
    if Layout.can_Switch_Share_On_All_Screens then
    
      table.insert(choices.views, {Text = "ShareAll", Color = "Black"})
      
      -- force 'share all' if it's available and the setting is on
      if Controls["Force Share All"].Boolean then
      
        Enqueue("zConfiguration Call Layout Style: ShareAll", 1)
        Controls["Layout Style"].Choices = { {Color = "Red", Text = "Forcing 'Share All'"} }
        
      else
      
        Controls["Layout Style"].Choices = choices.views
        
      end
      
    else
    
      Controls["Layout Style"].Choices = choices.views
      
    end

  end,
  
  ListParticipantsResult = function(ListParticipantsResult)
        
    if ListParticipantsResult.event == "ZRCUserChangedEventLeftMeeting" then return RemoveParticipant(ListParticipantsResult.user_id) end
    
    if (updateParticipantBypass) then return print("Temporarily Bypassing Participant Updates.") end

    if ListParticipantsResult.user_id then 
      
      UpdateParticipant(ListParticipantsResult)
      
    else
      
      participantsReceived = true
      participants_list = {}
      for i, tbl in pairs(ListParticipantsResult) do UpdateParticipant(tbl, true) end
      
    end
        
  end,
  
  Login = function(Login)
  
    --Controls["ZAAPI Release"].String = Login["ZAAPI Release"]
    --Controls["Zoom Room Release"].String = Login["Zoom Room Release"]
  
  end,
  
  MeetingNeedsPassword = function(MeetingNeedsPassword)
        
    if MeetingNeedsPassword.needsPassword then
      SetLED("Meeting Needs Password", MeetingNeedsPassword.needsPassword)
      Timer.CallAfter(function() SetLED("Meeting Needs Password", false) end, 2)
    end
  
  end,
  
  NeedWaitForHost = function(NeedWaitForHost)
      
    SetLED("Waiting for Host", NeedWaitForHost.Wait)
  
  end,
  
  NumberOfScreens = function(NumberOfScreens)
      
    Controls["Number of Screens"].String = NumberOfScreens.NumberOfScreens
    
    for i = 1, 4 do
      Controls[string.format("Pin Status %d", i)].IsDisabled = i > tonumber(NumberOfScreens.NumberOfScreens)
      Controls[string.format("Pin to Screen %d", i)].IsDisabled = i > tonumber(NumberOfScreens.NumberOfScreens)
    end
    
  end,
  
  PhonebookBasicInfoChange = function(PhonebookBasicInfoChange)
        
    print(rapidjson.encode(PhonebookBasicInfoChange, {pretty = true}))
    
    Controls['Number of Zoom Rooms'].String = PhonebookBasicInfoChange.numberOfZoomRoom
    Controls['Number of Normal Contacts'].String = PhonebookBasicInfoChange.numberOfNormalContact
    Controls['Number of Legacy Rooms'].String = PhonebookBasicInfoChange.numberOfLegacyRoom
    Controls['Total Contacts'].String = PhonebookBasicInfoChange.total
    
    -- when the SSH socket reconnects, it takes a few moments before the non-legacy contacts are available. Wait until they are available before importing contacts.
    if (PhonebookBasicInfoChange.numberOfNormalContact > 0) or (PhonebookBasicInfoChange.numberOfZoomRoom > 0) then
      
      contactsImported = true
      
      SetStatus(0, "")
      
      Enqueue("zCommand Bookings List")
  
      Enqueue("zStatus Capabilities")
      
      Enqueue("zStatus SystemUnit")
      
      Enqueue("zConfiguration Client appVersion")
      
      Enqueue("zstatus NumberOfScreens")
      
      poll_timer:Start(1.5)
      
    end
    
  end,
  
  PhonebookListResult = function(PhonebookListResult)
        
    local this = PhonebookListResult
    
    phonebookReceived = true
    
    UpdatePhonebook(this)
    
  end,
      
  PinVideoOnScreen = function()
  
  end,
  
  Phonebook = function(Phonebook)
    
    if Phonebook['Added Contact'] then
    
      print(string.format("Adding Contact '%s'", Phonebook['Added Contact'].screenName))
    
    elseif Phonebook['Updated Contact'] then
    
      if (not presence_updates) then presence_updates = {} end
      table.insert(presence_updates, Phonebook['Updated Contact'])
      
    end
    
  end,
  
  PinStatusOfScreenNotification = function(PinStatusOfScreenNotification)
        
    local props = PinStatusOfScreenNotification
    
    local screen = tonumber(props.screen_index) + 1
    
    local participant = participants_list[props.pinned_user_id] and participants_list[props.pinned_user_id].name or "None"
    
    Controls[string.format("Pin Status %d", screen)].String = participant
    
    print(string.format("Screen: %d, Pinned Participant: %s", screen, participant))
      
  end,
  
  Sharing = function(Sharing)
        
    Controls["Sharing Display State"].String = Sharing.dispState
  
    SetLED("Sharing Instructions Visible", (Sharing.dispState ~= "None"))
    
    Controls["Presentation Pairing Code"].String = Sharing.directPresentationPairingCode
  
    Controls["Presentation Sharing Key"].String = Sharing.directPresentationSharingKey
    
    Controls["Sharing WiFi Name"].String = Sharing.wifiName
    
    Controls["Sharing Server Name"].String = Sharing.serverName
    
    Controls["Sharing Password"].String = Sharing.password
    
    SetLED("Is Airplay Sharing", Sharing.isAirHostClientConnected)
    
    SetLED("Is Black Magic Connected", Sharing.isBlackMagicConnected)
    
    SetLED("Is Black Magic Data Available", Sharing.isBlackMagicDataAvailable)
    
    SetLED("Is Black Magic Sharing", Sharing.isSharingBlackMagic)
    
    SetLED("Is Direct Presentation Connected", Sharing.isDirectPresentationConnected)
  
  end,
  
  SharingState = function(SharingState)
        
    if SharingState.state then
      Controls["Sharing Status"].String = SharingState.state
      if SharingState.state ~= "None" then
        print("Sharing Event Received - Firing 'Sharing Event' Trigger")
        Controls["Sharing Event Trigger"]:Trigger()
      end
    end
    
    if SharingState.paused then SetLED("Sharing Paused", (SharingState.paused == "on")) end
    
  end,
  
  SpotlightStatusNotification = function(SpotlightStatusNotification)
  
    print(string.format("Spotlight Present: %s, User ID: %s", SpotlightStatusNotification.present, SpotlightStatusNotification.user_id))
    
    SetLED("Spotlight Active", SpotlightStatusNotification.present)
    
    Controls["Spotlight Status"].String = (SpotlightStatusNotification.present == "true") and participants_list[SpotlightStatusNotification.user_id].name or "None"
    
  end,
  
  StartLocalPresentMeeting = function(StartLocalPresentMeeting)
    
  end,
  
  SystemUnit = function(SystemUnit)
    
    --print(rapidjson.encode(SystemUnit, {pretty = true}))

    if (not contactsImported) then return end
    
    if SystemUnit.room_info then
      Controls["Room Name"].String = (SystemUnit.room_info and SystemUnit.room_info.room_name) and SystemUnit.room_info.room_name
      --SetLED("Is Auto Answer Enabled", SystemUnit.room_info.is_auto_answer_enabled)
    end
    
    -- this is the room PMI
    local pmi = SystemUnit.meeting_number
    Controls["Room PMI"].String = string.format("%s %s %s", pmi:sub(1, 3), pmi:sub(4, 7), pmi:sub(8))
    
    Controls["Room Version"].String = SystemUnit.room_version
    
  end,
  
  TreatedIncomingCallIndication = function(TreatedIncomingCallIndication)
        
    SetLED("Incoming Call", false)
    
    Controls["Caller Name"].String = "-"
  
  end,
  
  UpdateCallRecordInfo = function(UpdateCallRecordInfo)
  
    SetLED("Am I Recording", UpdateCallRecordInfo.amIRecording)
    SetLED("Can Record", UpdateCallRecordInfo.canRecord)
    SetLED("Meeting is Being Recorded", UpdateCallRecordInfo.meetingIsBeingRecorded)
    SetLED("Email Required", UpdateCallRecordInfo.emailRequired)
  
  end,
  
  Video = function(Video)
        
    if (Video.Optimizable) then SetLED("Is Video Optimizable", Video.Optimizable) end
    
    if (Video.Camera) then
    
      if (Video.Camera.Mirror) then Controls["Camera Mirror"].Boolean = Video.Camera.Mirror end
      
      if (Video.Camera.selectedId) then BuildCameraInputChoices(Video.Camera.selectedId) end
      
    end
    
  end,
  
  VideoCameraLine = function(VideoCameraLine)
    
    cameraConfigurationReceived = true
    
    camera_lines = {}
    
    for i, tbl in pairs(VideoCameraLine) do
      camera_lines[tbl.id] = {}
      camera_lines[tbl.id]['name'] = tbl.Name
      camera_lines[tbl.id]['alias'] = tbl.Alias
      camera_lines[tbl.id]['ptzComId'] = (i == 1 and 0 or tbl.ptzComId)
    end
    
    Enqueue("zConfiguration Video Camera selectedId")
    
  end
        
}

function Initialize()
  
  
  Controls["IP Address"].Color = "White"
  Controls['Call Ended by Host Mode'].Choices = {'Always Trigger', 'Auto-Answered Calls Only'}
  if Controls['Call Ended by Host Mode'].String == "" then Controls['Call Ended by Host Mode'].String = 'Always Trigger' end

  ResetParticipantsList()
  
  ResetTimers()

  ResetVariables()
  
  if not Controls["In Call"].Boolean then
  
      SetLED("In Call Presentation", false)
      
  end
  
  ResetControls()
end

function ResetTimers()
  poll_timer:Stop()
  queue_timer:Stop()
  phonebookTimer:Stop()
end

function ResetVariables()
  commandQueue = {}
  phonebookIsFetching = false
  phonebookReceived = false
  contactsImported = false
  cameraConfigurationReceived = false
  audioInputConfigurationReceived = false
  audioOutputConfigurationReceived = false
  callWasAutoAnswered = false
  canHangup = true
end

function Connect()
  
  if zoomRoom.IsConnected then zoomRoom:Disconnect() end
  
  -- set the 'connected' indicator
  SetLED("Connected", false)
  
  if not Controls["Connect"].Boolean then SetStatus(3, "Component Manually Disconnected"); Initialize() return zoomRoom:Disconnect() end
  
  ip = Controls['IP Address'].String:match('(%d?%d?%d%.%d?%d?%d%.%d?%d?%d%.%d?%d?%d)');
  
  Controls["IP Address"].Color = ip and 'Green' or 'Red'
  
  if not ip then return print("User.Error: IP address invalid") end
  
  print("SSH.Info: Connecting...")
  
  zoomRoom:Connect(ip, 2244, "zoom", Controls.Password.String)
end

function SetStatus(code, message)

  Controls["Status"].Value = code
  Controls["Status"].String = string.format("%s: %s", message, ip and ip or "None")
  
  if (code ~= 0) and (message ~= "") then return print(string.format("User.Info: Settings Status with Code: '%d', Message: '%s'", code, message)) end
  
end; SetStatus(3, "")

-- --[[function EventLog(log, severity)
--   Controls["Log Entry"].String = string.format("%s: %s", Controls["EventLog Prefix"].String, log)
--   Controls["Log Severity"].String = severity
--   if not sock.IsConnected then return end
--   Controls["Log Trigger"]:Trigger()
-- end]]

function ResetInCallControls()
  -- reset in call toggles
  for i, control_name in ipairs(In_Call_Toggles) do
    Controls[control_name].Boolean = false
  end
  
  for i, control_name in ipairs(In_Call_LEDs) do
    SetLED(control_name, false)
  end
end

function ResetControls()
  
  Controls["Booking List"].Choices = {}; Controls["Booking List"].String = ""
  Controls["Participant List"].Choices = {}; Controls["Participant List"].String = ""
  Controls["Participant Cameras"].Choices = {}; Controls["Participant Cameras"].String = ""
  Controls["Phonebook"].Choices = {}; Controls["Phonebook"].String = ""
  Controls["Camera Lines"].Choices = {}; Controls["Camera Lines"].String = ""
  Controls["Audio Input Lines"].Choices = {}; Controls["Audio Input Lines"].String = ""
  Controls["Audio Output Lines"].Choices = {}; Controls["Audio Output Lines"].String = ""
  Controls["Layout Style"].Choices = {}; Controls["Layout Style"].String = ""
  
  -- reset text indicators
  for i, control_name in ipairs(Text_Indicators) do
    if not Controls[control_name] then print(control_name) end
    Controls[control_name].String = ""
  end
  
  -- reset LED indicators
  for i, control_name in ipairs(LED_Indicators) do
    SetLED(control_name, false)
  end
  
  ResetInCallControls()
  
end

function DisableParticipantControls(bool)
  Controls["Mute Participant Video"].IsDisabled = bool
  Controls["Mute Participant Mic"].IsDisabled = bool
  Controls["Unpin Participant"].IsDisabled = bool
  Controls["Allow Participant Record"].IsDisabled = bool
  Controls["Disable Participant Record"].IsDisabled = bool
  Controls["Spotlight Participant"].IsDisabled = bool
  Controls["Spotlight Status"].IsDisabled = bool
  Controls["Remove Spotlight"].IsDisabled = bool
  Controls["Expel Participant"].IsDisabled = bool
  
  if (not bool) then return end
  
  SetLED("Participant Can Record", false)
  SetLED("Participant is Recording", false)
end

function SetLED(name, bool)
  --print(string.format("User.Info: Setting LED '%s' as '%s'", name, tostring(bool)))
  Controls[name].Boolean = bool
  Controls[name].Color = (bool and "Lime" or "DarkRed")
end

function Poll()
  
  poll_timer:Stop()
  
  if (Controls["Force Hangup"].Boolean) and (Controls['In Call'].Boolean) and (canHangup) and (not Controls["Incoming Call"].Boolean) then MeetingEnd() end
  
  if (not phonebookReceived) and (not pendingFirstPhonebookResult) then print("Fetching Phonebook..."); ResetPhonebookList() end
  if (not cameraConfigurationReceived) then Enqueue("zStatus Video Camera Line") end
  if (not audioInputConfigurationReceived) then Enqueue("zStatus Audio Input Line") end
  if (not audioOutputConfigurationReceived) then Enqueue("zStatus Audio Output Line") end
  
  if Controls["In Call Presentation"].Boolean and Controls["Share HDMI Automatically in Presentation"].Boolean then Enqueue("zCommand Call Sharing HDMI Start", 1) end
  
  if inCall and (not hangingUp) then
    
    Enqueue("zCommand Call Info", 1)
    
    Enqueue("zStatus Call Layout")
    
    Enqueue("zStatus Video Optimizable")
    
    Enqueue("zStatus Sharing")
    
    Enqueue("zConfiguration Video Camera Mirror")
    
    Enqueue("zConfiguration Call Camera mute")
    
    Enqueue("zConfiguration Call Microphone mute")
    
    Enqueue("zCommand Call ListParticipants")
    
    Enqueue("zConfiguration Call MuteUserOnEntry Enable")
    
    Enqueue("zConfiguration Call ClosedCaption Visible")
    
    Enqueue("zConfiguration Call Lock Enable")
    
    Enqueue("zStatus CameraShare")
    
  else
  
    if (not Controls["Force Hangup"].Boolean) and Controls["Force Local Presentation"].Boolean then
    
      print("Zoom.Info: Forcing Local Presentation")
    
      StartLocalPresentation()
    end
    
  end
  
  Enqueue("zStatus Call Status")
  
  Enqueue("zCommand Bookings Update")
  
  DisableParticipantControls((selectedParticipant == nil))
  
  poll_timer:Start(pollRate)
end

function Enqueue(command, position)

  -- check if socket is connected
  if not zoomRoom.IsConnected then print("Connecting..."); Connect() end
  
  -- start the queue timer again if the queue was empty prior to this enqueue
  if not commandQueue[1] then queue_timer:Start(0) end
  
  -- put priority commands to the front of the queue
  if position then
    table.insert(commandQueue, position, command)
  return end
  
  table.insert(commandQueue, command)
end

function Dequeue()
  
  queue_timer:Stop()
  
  if not commandQueue[1] then return print("User.Info: No Commands in Queue") end
  
  -- write the command to socket
  Send(commandQueue[1])
  
  -- remove the command after sending
  table.remove(commandQueue, 1)
  
  -- stop the queue timer if the queue is now empty
  if commandQueue[1] then queue_timer:Start(commandRate) return end
end

function Send(s)

  if not zoomRoom.IsConnected then return print("SSH.Warning: Socket is Not Connected") end
  --print(s)
  zoomRoom:Write(s.."\r")
end

----------------------------
----- Helper Functions -----
----------------------------

function GetIcon(state)

  local icon

  if (Properties["List Box Style"].Value == "HTML5 Compatible") then
    icon = ""
  else
    icon = state and utf8.char(10687) or utf8.char(9675)
  end

  return icon

end

function GetListColor(func, state)

  local color

  if (Properties["List Box Style"].Value == "HTML5 Compatible") then
    color = state and Properties['Highlight Color'].Value or ""
  else
    color = func()
  end

  return color

end

function BuildParticipantChoices(tbl)

  choices['participants'] = {}

  for id, participant in pairs(tbl) do

    table.insert(choices.participants, {
      Text = string.format("%s%s", participant.name, (participant.is_host and " (Host)" or "")),
      selected = participant.selected,
      Icon = GetIcon(participant.selected),
      Color = GetListColor(function()
        return ""
      end, participant.selected),
      id = id,
      is_myself = participant.is_myself,
      camera = {
        am_i_controlling = participant.camera.props.am_i_controlling
      },
      is_audio_muted = participant['is_audio_muted'],
      is_video_muted = participant['is_video_muted']
    })
    
    if participant.is_myself then myId = id end
  end
  
  Controls["Participant List"].Choices = choices.participants
  
end

function BuildCameraChoices(tbl)

  choices['cameras'] = {}

  for id, participant in pairs(tbl) do
    
    local selected = current_cam_id == 0 and participant.is_myself
    
    if not selected then selected = (current_cam_id == id) end

    table.insert(choices.cameras, {
      Text = string.format("%s's Camera", participant.name),
      Color = GetListColor(function()
        local color = (participant.camera.props.am_i_controlling or participant.is_myself) and "Black" or "Red"
        return color
      end, selected),
      Icon = GetIcon(selected),
      id = id,
      is_myself = participant.is_myself,
      camera = {
        am_i_controlling = participant.camera.props.am_i_controlling
      }
    })
  end

  Controls["Participant Cameras"].Choices = choices.cameras
  
end

function BuildPhonebookChoices(tbl, is_clearing)
  
  print("Contacts.Info: Building Phonebook Choices...")
  
  choices['phonebook'] = {}
  
  SetLED("Contacts Filtering", ((Controls['Contacts Search'].String ~= "") or Controls['Filter for Zoom Rooms Only'].Boolean) )
  
  local chunkTimer = Timer.New()
  
  -- chunk size to iterate over when compiling list box, to avoid execution limit for massive phonebooks
  local chunk = 100
  local delay = 0.001
  
  -- maximum contacts to display on the list box at once, to avoid performance issues. using the search feature will narrow the results table
  local max_contacts = 100
  
  local checked_contacts = 0
  local start, finish = 1, chunk
  
  ----- Local Functions -----
  
  local function CompilePhonebook()
  
    print(string.format("Contacts.Info: %d/%d Contacts Meet the Search & Filter Criteria", #choices.phonebook, checked_contacts))
    
    if #choices.phonebook > max_contacts then
    
      print("Contacts.Info: Cannot Compile List - Too Large")
      
      Controls.Phonebook.Choices = {
        {Text = "Too Many Results;", Color = "Orange"},
        {Text = "Please Narrow Search.", Color = "Orange"}
      }
      
    else
      
      print("Contacts.Info: Compiling Contacts List Box")
      
      -- subscribe to these contacts
      for i, contact in ipairs(choices.phonebook) do
        local position = phonebook.positions[contact.jid]
        print(string.format("Subscribing to Contact [%d] '%s'", position, phonebook.contacts[position].name))
        Enqueue(string.format("zcommand phonebook subscribe offset: %d limit: 1", position))
      end
      
      -- clear unused variables
      chunkTimer = nil
      chunk = nil
      delay = nil
      max_contacts = nil
      checked_contacts = nil
      start, finish = nil, nil
  
      Controls.Phonebook.Choices = choices.phonebook
      Controls["Phonebook"].String = ""
      
    end
  end
  
  local function CheckSearch(contact, i)
  
    if string.lower(contact.name):find(string.lower(Controls["Contacts Search"].String)) then
      
      local status = string.match(contact.presence, "PRESENCE_(%w+)")
      
      if status and status ~= "DND" then status = string.upper(string.sub(status, 1, 1)).. string.lower(string.sub(status, 2)) end
      
      if (not phonebook.contacts[i]) then return end

      table.insert(choices.phonebook, {
        Text = string.format("%s (%s)", contact.name, status),
        Color = GetListColor(function()
            local color = ((status == "DND") or (status == "Busy")) and "Red" or (status == "Online") and "Green" or (status == "Away") and "Gray" or "Black"
            return color
        end, false),
        jid = contact.jid,
        selected = phonebook.contacts[i].selected,
        Icon = GetIcon(phonebook.contacts[i].selected),
        position_in_phonebook = i
      })
      
    end
  end
  
  ----- Timer EventHandlers -----
  
  chunkTimer.EventHandler = function(t)
  
    t:Stop()
    
    -- phonebook can be off by (+10) contacts - sometimes the phonebook doesn't update the number of contacts quickly, so this serves as a buffer so the phonebook isn't stuck in an import look untiles it upades.
    if (#phonebook.contacts > tonumber(Controls['Total Contacts'].String) + 10) then t:Stop(); print("[Error Importing Contacts (Double Import Somewhere) - Retrying]"); ResetPhonebookList() return end

    local count = 0
    
    for i = start, finish do
      
      -- if we run out of phonebook entries, break the loop
      if not tbl[i] then print("Contacts.Info: Ran out of Phonebook Entries - Breaking Scan Loop") break end
      
      -- if we hit the chunk limit, return here and run the chunk timer again. if we don't hit the chunk limit, then we must be finished and the code below will run.
      if count >= chunk then t:Start(delay); return print(string.format("Contacts.Info: Chunk Completed (Chunk Size = %d)", count)) end
      
      if (is_clearing == true) then tbl[i].selected = false end
      
      --check filters and search criteria
      if Controls['Filter for Zoom Rooms Only'].Boolean then
        if tbl[i].isZoomRoom then CheckSearch(tbl[i], i) end
      else
        CheckSearch(tbl[i], i)
      end
      
      checked_contacts = checked_contacts + 1
      count = count + 1
      
    end
    
    -- increment the finish & start
    start = start + chunk
    finish = finish + chunk
    
    -- if we're not done, run another chunk
    if (checked_contacts < #phonebook.contacts) then t:Start(delay) return end
    
    count = nil
    
    print("Contacts.Info: Scan Completed - Checked all Contacts")
    
    CompilePhonebook(choices.phonebook)
  end
  
  ----- Running Code Starts Here -----
  
  print("Contacts.Info: Scanning Contacts...")
  
  chunkTimer:Start(delay)
end

function BuildBookingChoices(tbl)

  choices['bookings'] = {}

  for number, booking in pairs(tbl) do
      table.insert(choices.bookings, {
        Text = string.format("%s", booking.name),
        Color = "Black",
        number = number
      })
  end

  Controls["Booking List"].Choices = choices.bookings
  
end

function GetCameraPtzID()
  
  local participant = rapidjson.decode(Controls["Participant Cameras"].String)
  
  current_cam_id = participant.is_myself and 0 or participant.id
  current_cam_global_id = participant.id
  
  -- request control of the selected camera
  if not participant.camera.am_i_controlling and not participant.is_myself then
    print(string.format("Not Controlling %s's Camera - Requesting Control", participant.Text))
    RequestControl()
  end
  
end

function SetCameraID()

  local camera = rapidjson.decode(Controls["Camera Lines"].String)
  
  if (not camera) then return print("No Camera Selected.") end

  print(string.format("Setting Camera Input to: %s", camera.Text))
  Enqueue(string.format("zConfiguration Video Camera selectedId: %s", camera.id))
end

function SetAudioInputID()

  local audio_input = rapidjson.decode(Controls["Audio Input Lines"].String)
  
  if (not audio_input) then return print("No Audio Input Selected.") end

  print(string.format("Setting Audio Input to: %s", audio_input.Text))
  Enqueue(string.format("zConfiguration Audio Input selectedId: %s", audio_input.id))
end

function SetAudioOutputID()

  local audio_output = rapidjson.decode(Controls["Audio Output Lines"].String)
  
  if (not audio_output) then return print("No Audio Output Selected.") end

  print(string.format("Setting Audio Output to: %s", audio_output.Text))
  Enqueue(string.format("zConfiguration Audio Output selectedId: %s", audio_output.id))
end

function BuildAudioInputChoices(idx)
  
  choices['audio_input'] = {}

  for id, tbl in pairs(audio_input_lines) do
    table.insert(choices.audio_input, {
      Text = tbl.name,
      id = id,
      Icon = GetIcon((id == idx)),
      Color = GetListColor(function()
        return ""
      end, (id == idx)),
    })
  end
  
  Controls["Audio Input Lines"].Choices = choices.audio_input
  
end

function BuildAudioOutputChoices(idx)

  choices['audio_output']= {}

  for id, tbl in pairs(audio_output_lines) do
    table.insert(choices.audio_output, {
      Text = tbl.name,
      id = id,
      Icon = GetIcon((id == idx)),
      Color = GetListColor(function()
        return ""
      end, (id == idx)),
    })
  end
  
  Controls["Audio Output Lines"].Choices = choices.audio_output
  
end

function BuildCameraInputChoices(idx)

  choices['camera_input'] = {}

  for id, tbl in pairs(camera_lines) do
    table.insert(choices.camera_input, {
      Text = tbl.name,
      id = id,
      Icon = GetIcon((id == idx)),
      Color = GetListColor(function()
        return ""
      end, (id == idx)),
    })
  end
  
  selected_camera_line = idx
  
  Controls["Camera Lines"].Choices = choices.camera_input
  
end

function ResetParticipantsList()
  
  participants_list = {}
  
  Controls["Participant List"].Choices = {}
  Controls["Participant Cameras"].Choices = {}
  
end

-- if the CLI misses a phonebook response, this should start the chain again from where it was up to.
phonebookTimer = Timer.New()

phonebookTimer.EventHandler = function()
  
  print("Contacts.Info: Checking for More Contacts...")
  
  Enqueue(string.format("zCommand Phonebook List Offset: %d Limit: %d", offset, limit), 1) 

end

function ResetPhonebookList()
  
  SetStatus(0, "Fetching Phonebook...")
  phonebookIsFetching = true
  phonebook = {}
  phonebook['contacts'] = {}
  phonebook['positions'] = {}
  presence_updates = {}
  PresenceUpdateTimers[1]:Stop()
  PresenceUpdateTimers[2]:Stop()
  
  Controls["Phonebook"].Choices = {"Fetching Phonebook..."}
  
  offset = 0
  limit = 1000
      
  Send(string.format("zCommand Phonebook List Offset: %d Limit: %d", offset, limit))
  
end

function UpdatePhonebook(this)
  
  phonebookTimer:Stop()
  
  for i, contact in ipairs(this.Contacts) do InsertContact(contact) end
  
  print(string.format("Contacts.Info: Added %d Contacts out of %s (Limit)", #this.Contacts, limit))
    
  if #this.Contacts >= limit then
  
    print("Contacts.Info: Checking for More Contacts...")
    
    offset = offset + limit
    
    Enqueue(string.format("zCommand Phonebook List Offset: %d Limit: %d", offset, limit), 1)
    
    phonebookTimer:Start(5)
    
  else
  
    print(string.format("Contacts.Info: %d Total Contacts Imported from Zoom", #phonebook.contacts))
    
    SetStatus(0, "Phonebook Received")
    
    phonebookIsFetching = false
    
    BuildPhonebookChoices(phonebook.contacts)
    
    phonebookTimer:Stop()
    
    PresenceUpdateTimers[1]:Start(10)
  end
end

function InsertContact(contact)
  
  if not contact then return end
  
  table.insert(phonebook.contacts, {
    jid = contact.jid,
    name = contact.screenName,
    presence = contact.presence,
    isZoomRoom = contact.isZoomRoom,
    selected = false
  })
  
  phonebook.positions[contact.jid] = #phonebook.contacts
  
  --print(string.format("Contact: '%s', is Zoom Room: %s, is Available: %s, Email: %s", contact.screenName, contact.isZoomRoom, contact.presence, contact.email))
end

-- update all the updated contacts, then compile
PresenceUpdateTimers[1].EventHandler = function()
  
  if (not (#presence_updates > 0)) then return end
  
  print(string.format("Contacts.Info: %d Contact 'Presence' Updates Available", #presence_updates))
  
  PresenceUpdateTimers[2]:Start(0)

end

PresenceUpdateTimers[2].EventHandler = function(t)
  
  t:Stop()
  
  for i = 1, 500 do
  
    local update = table.remove(presence_updates, 1)
    
    if (not update) then print("No More Updates."); break; end
    
    local position = phonebook.positions[update.jid]
    local contact = phonebook.contacts[position]
    
    if (not contact) then return end
    
    print(string.format("Updating Contact [%d] '%s' from '%s' to '%s'", position, update.screenName, contact.presence, update.presence))
    
    contact.jid = update.jid
    contact.name = update.screenName
    contact.presence = update.presence
    contact.isZoomRoom = update.isZoomRoom
    
  end
  
  if ((#presence_updates) <= 0) and contactsImported then
  
    print("Finished Processing Presence Updates.")
    BuildPhonebookChoices(phonebook.contacts)
  
  return end
  
  PresenceUpdateTimers[2]:Start(0.01)
end

function UpdateParticipant(this, isFirstImport)
  
  --print(string.format("Camera: %s\nCan Request: %s\nAm Controlling: %s\nCan Move: %s\nCan Zoom: %s", this.user_name, this["camera_status can_i_request_control"], this["camera_status am_i_controlling"], this["camera_status can_move_camera"], this["camera_status can_zoom_camera"]))

  if (not participants_list[this.user_id]) then participants_list[this.user_id] = {} end
  participants_list[this.user_id]['camera'] = {}
  participants_list[this.user_id]['camera']['props'] = {}
  
  participants_list[this.user_id]['selected'] = (selectedParticipant and selectedParticipant.id == this.user_id)
  
  participants_list[this.user_id]['name'] = string.format("%s%s", this.user_name, this.is_myself and " (This Zoom Room)" or "")
  participants_list[this.user_id]['id'] = this.user_id
  participants_list[this.user_id]['is_myself'] = this.is_myself
  participants_list[this.user_id]['is_host'] = this.is_host
  participants_list[this.user_id]['is_audio_muted'] = (this['audio_status state'] == "AUDIO_MUTED")
  participants_list[this.user_id]['is_video_muted'] = not this['video_status is_sending']
  participants_list[this.user_id]['can_record'] = this['can_record']
  participants_list[this.user_id]['is_recording'] = this['is_recording']
  participants_list[this.user_id]['camera']['props']['am_i_controlling'] = this["camera_status am_i_controlling"]
  
  BuildParticipantChoices(participants_list)
  BuildCameraChoices(participants_list)
  
  if selectedParticipant and (selectedParticipant.id == this.user_id) then
    print(string.format("Updating Selected Participant '%s', Audio Mute: %s, Video Mute: %s, Can Record: %s, Is Recording: %s",
      participants_list[this.user_id].name,
      participants_list[this.user_id].is_audio_muted,
      participants_list[this.user_id].is_video_muted,
      participants_list[this.user_id].can_record,
      participants_list[this.user_id].is_recording
    ))
    
    --SetLED("Participant is Audio Muted", participants_list[this.user_id].is_audio_muted)
    --SetLED("Participant is Video Muted", participants_list[this.user_id].is_video_muted)
    Controls['Mute Participant Mic'].Boolean = participants_list[this.user_id].is_audio_muted
    Controls['Mute Participant Video'].Boolean = participants_list[this.user_id].is_video_muted
    SetLED("Participant Can Record", participants_list[this.user_id].can_record)
    SetLED("Participant is Recording", participants_list[this.user_id].is_recording)
  
  end
end

function RemoveParticipant(this_id)

  print("Attempting to Remove Participant")
  participants_list[this_id] = nil
  
  BuildParticipantChoices(participants_list)
  BuildCameraChoices(participants_list)
end

-------------------------
----- SSH Functions -----
-------------------------

zoomRoom.Connected = function()
  
  Send("format json")

  SetStatus(5, "Importing Contacts...")
  
  print("SSH.Info: Connected")
  
  SetLED("Connected", true)
  
  --[[ doesn't apply to json responses
  Enqueue("zFeedback Register Op: ex Path: /Event/InfoResult/Info/callin_country_list")
  
  Enqueue("zFeedback List")]]
  
  --MeetingEnd()
  ResetVariables()
  ResetTimers()
  
end

zoomRoom.Reconnect = function()
  print("SSH.Warning: Connection Reconnecting...")
  SetLED("Connected", false)
end

zoomRoom.Data = function()
  
  --SetStatus(0, "")
  
  -- read socket buffer
  line = ""
  
  while line ~= nil do
    
    line = zoomRoom:ReadLine(TcpSocket.EOL.Custom, '"\r\n}\r\n')

    if not line then return end
    
    json_start = line:find("{\r\n")
    
    line = line:sub(json_start)
    
    line = line..'"\n}'
    
    --print(line)
    
    data = rapidjson.decode(line)
    
    if not data then return print(string.format("UNREADABLE DATA: '%s'", line)) end
    
    --print(rapidjson.encode(data, {pretty = true}))
    
    local key = data.topKey:gsub(" ", "")
    
    if data.Status.state == "Error" then print(string.format("Zoom.Error: Command: '%s', Error: '%s'", data.topKey, data.Status.message)) end
    
    if rapidjson.encode(data[data.topKey], {pretty = true}) == "{}" then return end
    
    local result, err = pcall(Zoom_Responses[key], data[data.topKey])
    
    if err then print(string.format("Parsing Error: '%s', Data: \n\n%s", err, rapidjson.encode(data, {pretty = true}))) end
    
  end
end

zoomRoom.Closed = function()
  print("SSH.Error: Connection Closed")
  SetStatus(2, "Connection Closed")
  SetLED("Connected", false)
  ResetControls()
end

zoomRoom.Error = function(s, err)
  print(string.format("SSH.Error: Error Occurred: %s", err))
  SetStatus(2, string.format("SSH Error Occurred: %s", err))
  SetLED("Connected", false)
  ResetControls()
end

zoomRoom.Timeout = function()
  print("SSH.Error: Connection Timed Out")
  SetStatus(2, "Connection Timed Out")
  SetLED("Connected", false)
  ResetControls()
end

zoomRoom.LoginFailed = function()
  print("SSH.Error: Login Failed")
  SetStatus(1, "Login Failed")
  SetLED("Connected", false)
  ResetControls()
end

-------------------------
----- EventHandlers -----
-------------------------

poll_timer.EventHandler = Poll

queue_timer.EventHandler = Dequeue

Controls["IP Address"].EventHandler = function() Initialize(); Connect() end
Controls["Connect"].EventHandler = Connect
Controls["Password"].EventHandler = function()  Initialize(); Connect() end

Controls["Meet Now"].EventHandler = function()
  ResetParticipantsList()
  
  if Controls["In Call Presentation"].Boolean then
    Enqueue("zCommand Call Sharing ToNormal", 1)
  else
    Enqueue("zCommand Dial StartPmi Duration: 30", 1)
  end
  
end

Controls["Join Meeting"].EventHandler = function()
  meeting_id_stored = Controls["Join Meeting ID"].String
  local command = (Controls["Join Meeting Password"].String == "") and string.format("zCommand Dial Join meetingNumber: %s", Controls["Join Meeting ID"].String) or string.format("zCommand Dial Join meetingNumber: %s password: %s", meeting_id_stored, Controls["Join Meeting Password"].String)
  if Controls["In Call"].Boolean then
    ResetParticipantsList()
    Enqueue("zCommand Call Leave", 1)
    Enqueue("zCommand Call Sharing HDMI Stop", 1)
    Timer.CallAfter(function() Enqueue(command, 1) end, 1)
  else
    Enqueue(command, 1)
  end
  
end

function MeetingEnd()
  hangingUp = true
  callWasAutoAnswered = false
  commandQueue = {}
  ResetParticipantsList()
  Enqueue("zCommand Call Disconnect", 1)
end

Controls["Meeting End"].EventHandler = MeetingEnd

Controls["Meeting Leave"].EventHandler = function()
  hangingUp = true
  callWasAutoAnswered = false
  commandQueue = {}
  SetLED("In Call Presentation", false)
  ResetParticipantsList()
  Enqueue("zCommand Call Leave", 1)
end



function CallAccept()
  
  if not callerJID then return print("Zoom.Error: No CallerJID to Accept/Reject") end
  print("Zoom.Info: Accepted Incoming Call")
  Enqueue(string.format("zCommand Call Accept callerJID: %s", callerJID), 1)
  Enqueue("zCommand Call Sharing HDMI Stop", 1)
  SetLED("Incoming Call", false)
  Controls["Caller Name"].String = ""
end; Controls["Call Accept"].EventHandler = CallAccept

Controls["Call Reject"].EventHandler = function()
  if not callerJID then return print("Zoom.Error: No CallerJID to Accept/Reject") end
  print("Zoom.Info: Rejected Incoming Call")
  Enqueue(string.format("zCommand Call Reject callerJID: %s", callerJID), 1)
  SetLED("Incoming Call", false)
  Controls["Caller Name"].String = ""
end

function StartLocalPresentation()
  if (global_status == "IN_MEETING") or (global_status == "CONNECTING_MEETING") then return print("Zoom.Info: Already In Call | Attemping to Connect") end
  Enqueue("zCommand Dial Sharing Duration: 30 displaystate: None password:", 1)
end

Controls["Start Local Presentation"].EventHandler = function()
  print("Zoom.Info: 'Start Local Presentation' Manually Triggered")
  StartLocalPresentation()
end

Controls["Sharing Instructions None"].EventHandler = function()
  Enqueue("zCommand Call SetInstructions Show: off Type: None", 1)
end

Controls["Sharing Instructions Laptop"].EventHandler = function()
  Enqueue("zCommand Call SetInstructions Show: on Type: Laptop", 1)
end

Controls["Sharing Instructions iOS"].EventHandler = function()
  Enqueue("zCommand Call SetInstructions Show: on Type: IOS", 1)
end

Controls["Start Sharing HDMI"].EventHandler = function()
  Enqueue("zCommand Call Sharing HDMI Start", 1)
end

Controls["Stop Sharing HDMI"].EventHandler = function()
  Enqueue("zCommand Call Sharing HDMI Stop", 1)
end

Controls["Stop Local Sharing"].EventHandler = function()
  Enqueue("zCommand Call Sharing Disconnect", 1)
end

Controls["Participant Cameras"].EventHandler = function(c)
  GetCameraPtzID()
  
  for i, choice in ipairs(choices.cameras) do
    choices.cameras[i].Icon = GetIcon((c.String == rapidjson.encode(choice)))
    choices.cameras[i].Color = GetListColor(function()
      return choices.cameras[i].Color
    end, (c.String == rapidjson.encode(choice)))
  end
  
  Controls["Participant Cameras"].Choices = choices.cameras; Controls["Participant Cameras"].String = ""
  
end

Controls["Set Camera"].EventHandler = SetCameraID

Controls["Set Audio Input"].EventHandler = SetAudioInputID

Controls["Set Audio Output"].EventHandler = SetAudioOutputID

micMuteTimer.EventHandler = function(t)
  t:Stop()
  micMuteBypass = false
end

Controls["Mute Mic"].EventHandler = function(c)
  Enqueue(string.format("zConfiguration Call Microphone mute: %s", (c.Boolean and "on" or "off")), 1)
  micMuteBypass = true
  micMuteTimer:Start(.5)
end

camMuteTimer.EventHandler = function(t)
  t:Stop()
  camMuteBypass = false
end

Controls["Mute Video"].EventHandler = function(c)
  Enqueue(string.format("zConfiguration Call Camera mute: %s", (c.Boolean and "on" or "off")), 1)
  camMuteBypass = true
  camMuteTimer:Start(.5)
end

Controls["Start Recording"].EventHandler = function()
  Enqueue("zCommand Call Record Enable: on", 1)
end

Controls["Stop Recording"].EventHandler = function()
  Enqueue("zCommand Call Record Enable: off", 1)
end

Controls["Mute All"].EventHandler = function()
  Enqueue("zCommand Call MuteAll mute: on", 1)
end

Controls["Unmute All"].EventHandler = function()
  Enqueue("zCommand Call MuteAll mute: off", 1)
end

Controls["Camera Mirror"].EventHandler = function(c)
  Enqueue(string.format("zConfiguration Video Camera Mirror: %s", (c.Boolean and "on" or "off")), 1)
end

Controls["Join Meeting from List"].EventHandler = function()
  local choice = rapidjson.decode(Controls["Booking List"].String)
  
  if not choice then return end
  
  Enqueue("zCommand Call Leave", 1)
  ResetParticipantsList()
  Timer.CallAfter(function() Enqueue(string.format("zCommand Dial Start meetingNumber: %s", choice.number), 1) end, 1)
end

Controls["Expel Participant"].EventHandler = function()

  if not myId or not selectedParticipant or (selectedParticipant.id == myId) then return print("Cannot Expel Myself...") end
  
  Enqueue(string.format("zCommand Call Expel Id: %s", selectedParticipant.id), 1)
  RemoveParticipant(selectedParticipant.id)
  
  selectedParticipant = nil
end

Controls["Participant List"].EventHandler = function(c)
  
  selectedParticipant = nil
  
  for id, participant in pairs(participants_list) do
    if (id == rapidjson.decode(c.String).id) then
        
        participant.selected = not participant.selected
        if participant.selected then selectedParticipant = participant end
        
    else
        
        participant.selected = false
        
    end
  end
  
  BuildParticipantChoices(participants_list)
  Controls["Participant List"].String = ""
  
  if not selectedParticipant then DisableParticipantControls(true) return end
  
  Controls['Mute Participant Mic'].Boolean = selectedParticipant.is_audio_muted
  Controls['Mute Participant Video'].Boolean = selectedParticipant.is_video_muted
  SetLED("Participant Can Record", selectedParticipant.can_record)
  SetLED("Participant is Recording", selectedParticipant.is_recording)
  
  DisableParticipantControls(false)

end

phonebookBypass = false
Controls["Phonebook"].EventHandler = function(c)
  
  if phonebookBypass then return print("Phonebook Selection: Double Trigger Detected, Ignoring 2nd Trigger") end
  
  phonebookBypass = true
  
  for i, choice in ipairs(choices.phonebook) do
  
    if c.String == rapidjson.encode(choice) then
      phonebook.contacts[choice.position_in_phonebook].selected = not phonebook.contacts[choice.position_in_phonebook].selected
      choices.phonebook[i].selected = phonebook.contacts[choice.position_in_phonebook].selected
    end

    choices.phonebook[i].Icon = GetIcon(choices.phonebook[i].selected)
    choices.phonebook[i].Color = GetListColor(function()
      return choices.phonebook[i].Color
    end, choices.phonebook[i].selected)
  end
  
  Controls["Phonebook"].Choices = choices.phonebook
  
  
  Timer.CallAfter(function() phonebookBypass = false end, 0.2)

end

Controls["Invite Contact"].EventHandler = function()
  
  local str = Controls['In Call'].Boolean and "zcommand call invite" or "zCommand Invite Duration: 30"
  
  for i, contact in ipairs(choices.phonebook) do
    if contact.selected then
      str = str .. string.format(" user: %s", contact.jid)
      print(str)
      print(string.format("Inviting Contact Name: %s, JID: %s", contact.Text, contact.jid))
    end
  end
  
  Enqueue(str, 1)
  
  -- reset selections
  for i, choice in ipairs(choices.phonebook) do
    phonebook.contacts[choice.position_in_phonebook].selected = false
    choices.phonebook[i].selected = phonebook.contacts[choice.position_in_phonebook].selected
    choices.phonebook[i].Icon = GetIcon(phonebook.contacts[choice.position_in_phonebook].selected)
    choices.phonebook[i].Color = GetListColor(function()
      return ""
    end, (c.String == phonebook.contacts[choice.position_in_phonebook].selected))
  end
  
  Controls["Phonebook"].Choices = choices.phonebook; Controls["Phonebook"].String = ""

end

screen_ids = {}
for i = 1, 4  do

  screen_ids[ Controls[string.format("Pin to Screen %d", i)] ] = i - 1
  
  Controls[string.format("Pin to Screen %d", i)].EventHandler = function(c)
    
    if not selectedParticipant then return print("Cannot Pin Participant - No ID Found") end
    
    local screen = screen_ids[c]

    Enqueue(string.format("zCommand Call Pin Id: %s Enable: On Screen: %s", selectedParticipant.id, screen), 1)
  end
  
end

Controls["Unpin Participant"].EventHandler = function()
  
  if not selectedParticipant then return print("Cannot Unpin Participant - None Selected") end
  
  Enqueue(string.format("zCommand Call Pin Id: %s Enable: Off", selectedParticipant.id), 1)
end

Controls["Spotlight Participant"].EventHandler = function()
  
  if not selectedParticipant then return print("Cannot Spotlight Participant - None Selected") end
  
  Enqueue(string.format("zCommand Call Spotlight Id: %s Enable: On", selectedParticipant.id), 1)
end

Controls["Remove Spotlight"].EventHandler = function()
  
  if not selectedParticipant then return print("Cannot Spotlight Participant - None Selected") end
  
  Enqueue(string.format("zCommand Call Spotlight Id: %s Enable: Off", selectedParticipant.id), 1)
end

Controls["Allow Participant Record"].EventHandler = function()
  
  if not selectedParticipant then return print("Cannot Allow Participant Record - None Selected") end
  
  Enqueue(string.format("zCommand Call Allowrecord Id: %s Enable: On", selectedParticipant.id), 1)
end

Controls["Disable Participant Record"].EventHandler = function()
  
  if not selectedParticipant then return print("Cannot Disable Participant Record - None Selected") end
  
  Enqueue(string.format("zCommand Call Allowrecord Id: %s Enable: Off", selectedParticipant.id), 1)
end

function SetView()
    
  local view = rapidjson.decode(Controls["Layout Style"].String)
  
  if (not view) then return print("Cannot Set View - No View Selected") end
  
  local view = view.Text

  Enqueue(string.format("zConfiguration Call Layout Style: %s", view), 1)
end

Controls["Set View"].EventHandler = SetView
--Controls["Layout Style"].EventHandler = SetView

participantBypassTimer.EventHandler = function(t)
  t:Stop()
  updateParticipantBypass = false
end

Controls["Mute Participant Mic"].EventHandler = function(c)

  if (not selectedParticipant) or not (selectedParticipant.id) then return print("No Participant Selected") end
  
  local state = (c.Boolean and "on" or "off")

  Enqueue(string.format("zcommand call muteparticipant mute: %s id: %s", state, selectedParticipant.id), 1)

  updateParticipantBypass = true
  participantBypassTimer:Start(2)
end

Controls["Mute Participant Video"].EventHandler = function(c)
  
  if (not selectedParticipant) or not (selectedParticipant.id) then return print("No Participant Selected") end
  
  local state = (c.Boolean and "on" or "off")

  Enqueue(string.format("zcommand call muteparticipantvideo mute: %s id: %s", state, selectedParticipant.id), 1)

  updateParticipantBypass = true
  participantBypassTimer:Start(2)
end

Controls["Filter for Zoom Rooms Only"].EventHandler = function() BuildPhonebookChoices(phonebook.contacts) end

Controls["Contacts Search"].EventHandler = function() BuildPhonebookChoices(phonebook.contacts) end

Controls["Clear Phonebook Selections"].EventHandler = function()

  BuildPhonebookChoices(phonebook.contacts, true)

end

Controls["Optimize Video"].EventHandler = function()
  if not Controls["Is Video Optimizable"].Boolean then return end
  Enqueue("zConfiguration Call Sharing optimize_video_sharing", 1)
end

Controls["Enable Mute on Entry"].EventHandler = function()
  Enqueue("zConfiguration Call MuteUserOnEntry Enable: on", 1)
end

Controls["Disable Mute on Entry"].EventHandler = function()
  Enqueue("zConfiguration Call MuteUserOnEntry Enable: off", 1)
end

Controls["Lock Call"].EventHandler = function()
  Enqueue("zConfiguration Call Lock Enable: on", 1)
end

Controls["Unlock Call"].EventHandler = function()
  Enqueue("zConfiguration Call Lock Enable: off", 1)
end

Controls["Closed Caption Visible"].EventHandler = function(c)
  Enqueue(string.format("zConfiguration Call ClosedCaption Visible: %s", (c.Boolean and "on" or "off")), 1)
end

Controls["Share Camera"].EventHandler = function()
  if not selected_camera_line then return print("Zoom.Error: No Camera ID - Please Select a Video Line") end
  Enqueue(string.format("zCommand Call ShareCamera id: %s Status: on", selected_camera_line), 1)
end

Controls["Refresh Phonebook"].EventHandler = ResetPhonebookList

-----------------------
----- PTZ Control -----
-----------------------

Controls["Request Control"].EventHandler = RequestControl

function RequestControl()
  
  if not current_cam_id then return print("Zoom.Error: No Camera ID - Please Select a Camera") end
  print(string.format("zCommand Call CameraControl Id: %d State: RequestRemote Action: Left", current_cam_id))
  Send(string.format("zCommand Call CameraControl Id: %d State: RequestRemote Action: Left", current_cam_id))
  
end

timer = Timer.New()

timer.EventHandler = function()
  Send(string.format("zCommand Call CameraControl Id: %d State: %s Action: %s", current_cam_id, "Continue", ptzAction))
end

camera_ptz = {"Left", "Right", "Up", "Down"}

for i = 1, 4 do
  Controls[string.format("Camera Control %d", i)].EventHandler = function(c)
    
    if not current_cam_id then return print("Zoom.Error: No Camera ID - Please Select a Camera") end
    ptzAction = camera_ptz[i]
    Send(string.format("zCommand Call CameraControl Id: %d State: %s Action: %s", current_cam_id, (c.Boolean and "Start" or "Stop"), camera_ptz[i]))
    
    if not c.Boolean then return timer:Stop() end
    timer:Start(.01)
  end
end

camera_zoom = {"In", "Out"}

for i = 1, 2 do
  Controls[string.format("Camera Zoom %d", i)].EventHandler = function(c)
  
    if not current_cam_id then return print("Zoom.Error: No Camera ID - Please Select a Camera") end
    ptzAction = camera_zoom[i]
    Send(string.format("zCommand Call CameraControl Id: %d State: %s Action: %s", current_cam_id, (c.Boolean and "Start" or "Stop"), camera_zoom[i]))
    
    if not c.Boolean then return timer:Stop() end
    timer:Start(.01)
  end
end

-----------------------
-----------------------
-----------------------

Initialize()

Connect()
