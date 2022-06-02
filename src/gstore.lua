colors = {
  none = {0, 0, 0, 0},
  primary = {165, 216, 246},
  secondary = {236, 222, 243},
  black = {50, 50, 50},
}


width = 250 -- scalable plugin width
control_depth = 16 -- scalable control depth
control_gap = 3 -- vertical space between controls

Sizes = {
  ["Button"] = {36, control_depth},
  ["Text"] = {(width - 30)/2, control_depth},
  ["Status"] = {width - 30, control_depth},
  ["LED"] = {16, control_depth},
  ["ListBox"] = {width - 30, (control_depth*5) + (control_gap*4)}
}

Master_Object = {
  {

      ["PageName"] = "Config",

      ["Groupings"] = {
          {
              ["Name"] = "Connection Settings",
              ["Depth"] = 7,
              ["Controls"] = {
                  {Name = "IP Address", PrettyName = "Connection~IP Address", Label = "IP", ControlType = "Text", PinStyle = "Both", UserPin = true, Size = Sizes.Text, GridPos = 1},
                  {Name = "Password", PrettyName = "Connection~Password", Label = "Password", ControlType = "Text", PinStyle = "Both", UserPin = true, Size = Sizes.Text, GridPos = 2},
                  {Name = "Connect", PrettyName = "Connection~Connect", Label = "Connect", ControlType = "Button", ButtonType = "Toggle", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 3},
                  {Name = "Connected", PrettyName = "Connection~Connected", Label = "Connected", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 4},
                  {Name = "Status", PrettyName = "Connection~Status", Label = "Connection Status", ControlType = "Indicator", IndicatorType = "Status", PinStyle = "Output", UserPin = true, Size = Sizes.Status, Width = "Full", GridPos = 6},
              },
          },
          {
              ["Name"] = "Audio Lines",
              ["Depth"] = 13,
              ["Controls"] = {
                  {Name = "Audio Input Lines", ControlType = "Text", Style = "ListBox", Size = Sizes.ListBox, Width = "Full", GridPos = 1},
                  {Name = "Set Audio Input", PrettyName = "Configuration~Set Audio Input", Label = "Audio Input", Legend = "Set", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 1},
                  {Name = "Audio Output Lines", ControlType = "Text", Style = "ListBox", Size = Sizes.ListBox, Width = "Full", GridPos = 8},
                  {Name = "Set Audio Output", PrettyName = "Configuration~Set Audio Output", Label = "Audio Output", Legend = "Set", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 8},    
              },
          },
          {
              ["Name"] = "Camera Lines",
              ["Depth"] = 7,
              ["Controls"] = {
                  {Name = "Camera Lines", ControlType = "Text", Style = "ListBox", Size = Sizes.ListBox, Width = "Full", GridPos = 1},
                  {Name = "Set Camera", PrettyName = "Configuration~Set Camera", Label = "Camera Input", Legend = "Set", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 1},
                  {Name = "Camera Mirror", PrettyName = "Configuration~Camera Mirror", Label = "Camera Mirror", ControlType = "Button", ButtonType = "Toggle", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 7},
              },
          },
      },

  },
  {

      ["PageName"] = "Room",

      ["Groupings"] = {
          {
              ["Name"] = "This Zoom Room",
              ["Depth"] = 5,
              ["Controls"] = {
                  --{Name = "ZAAPI Release", PrettyName = "Room Info~ZAAPI Release", Label = "ZAAPI Release", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 1},
                  --{Name = "Zoom Room Release", PrettyName = "Room Info~Zoom Room Release", Label = "ZR Release", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 2},
                  {Name = "App Version", PrettyName = "Room Info~App Version", Label = "App Version", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 1},
                  {Name = "Room Name", PrettyName = "Room Info~Name", Label = "Room Name", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 2},
                  {Name = "Room Version", PrettyName = "Room Info~Version", Label = "Room Version", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 3},
                  {Name = "Room PMI", PrettyName = "Room Info~PMI", Label = "Room PMI", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 4},
                  {Name = "Number of Screens", PrettyName = "Room Info~Number of Screens", Label = "# Screens", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 5},
              }
          },
          {
              ["Name"] = "Capabilities",
              ["Depth"] = 3,
              ["Controls"] = {
                  {Name = "Is Airhost Disabled", PrettyName = "Capabilities~Is Airhost Disabled", Label = "Airhost Disabled", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 1},
                  {Name = "Supports Pin and Spotlight", PrettyName = "Capabilities~Supports Pin and Spotlight", Label = "Pin and Spotlight", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 2},
                  {Name = "Supports Expel User Permanently", PrettyName = "Capabilities~Supports Expel User Permanently", Label = "Expel User Permanently", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 3},
                  --{Name = "Is Auto Answer Enabled", PrettyName = "Capabilities~Is Auto Answer Enabled", Label = "Auto Answer Enabled", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 4},
              }
          },
          {
              ["Name"] = "Plugin Settings",
              ["Depth"] = 5,
              ["Controls"] = {
                  {Name = "Force Local Presentation", PrettyName = "Plugin Settings~Force Local Presentation", Label = "Force Local Presentation", ControlType = "Button", ButtonType = "Toggle", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 1},
                  {Name = "Force Hangup", PrettyName = "Plugin Settings~Force Hangup", Label = "Force Hangup", ControlType = "Button", ButtonType = "Toggle", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 2},
                  {Name = "Force Share All", PrettyName = "Plugin Settings~Force Share All", Label = "Force Share All", ControlType = "Button", ButtonType = "Toggle", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 3},
                  {Name = "Auto Answer", PrettyName = "Plugin Settings~Auto Answer", Label = "Auto Answer", ControlType = "Button", ButtonType = "Toggle", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 4},
                  {Name = "Share HDMI Automatically in Presentation", PrettyName = "Plugin Settings~Share HDMI Automatically in Presentation", Label = "Auto Share HDMI", ControlType = "Button", ButtonType = "Toggle", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 5},
                  
              },
          },
      },

  },
  {

      ["PageName"] = "Admin",

      ["Groupings"] = {
          {
              ["Name"] = "Phonebook",
              ["Depth"] = 16,
              ["Controls"] = {
                {Name = "Number of Zoom Rooms", PrettyName = "Phonebook~Indicators~Number of Zoom Rooms", Label = "# Zoom Rooms", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 1},
                {Name = "Number of Normal Contacts", PrettyName = "Phonebook~Indicators~Number of Normal Contacts", Label = "# Normal Contacts", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 2},
                {Name = "Number of Legacy Rooms", PrettyName = "Phonebook~Indicators~Number of Legacy Rooms", Label = "# Legacy Rooms", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 3},
                {Name = "Total Contacts", PrettyName = "Phonebook~Indicators~Total Contacts", Label = "Total Contacts", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 4},
                  
                  {Name = "Phonebook", ControlType = "Text", Style = "ListBox", Size = Sizes.ListBox, Width = "Full", GridPos = 5},
                  {Name = "Refresh Phonebook", PrettyName = "Phonebook~Refresh Phonebook", Label = "Phonebook", Legend = "Load", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 5},
                  {Name = "Contacts Filtering", PrettyName = "Phonebook~Contacts Filtering", Label = "Contacts Filtering", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 12},
                  {Name = "Filter for Zoom Rooms Only", PrettyName = "Phonebook~Filter for Zoom Rooms Only", Label = "Zoom Rooms Only", ControlType = "Button", ButtonType = "Toggle", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 13},
                  {Name = "Contacts Search", PrettyName = "Phonebook~Contacts Search", Label = "Search", ControlType = "Text", PinStyle = "Input", UserPin = true, Size = Sizes.Text, GridPos = 14},
                  {Name = "Clear Phonebook Selections", PrettyName = "Phonebook~Clear Phonebook Selections", Label = "Clear Selections", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 15},
                  {Name = "Invite Contact", PrettyName = "Phonebook~Invite Contact", Label = "Invite Contact", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 16},
                  
              }
          },
          {
              ["Name"] = "Bookings",
              ["Depth"] = 6,
              ["Controls"] = {
                  {Name = "Booking List", ControlType = "Text", Style = "ListBox", Size = Sizes.ListBox, Width = "Full", GridPos = 1},
                  {Name = "Join Meeting from List", PrettyName = "Bookings~Join Booking from List", Label = "Bookings", Legend = "Join", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 1},
              }
          },
      },

  },
  {

      ["PageName"] = "Call",

      ["Groupings"] = {
          {
              ["Name"] = "Status",
              ["Depth"] = 11,
              ["Controls"] = {
                  {Name = "Call Status", PrettyName = "In Call~Status~Call Status", Label = "Call Status", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Status, Width = "Full", GridPos = 1},
                  {Name = "Meeting ID", PrettyName = "In Call~Status~Meeting ID", Label = "Meeting ID", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 4},
                  {Name = "Meeting Password", PrettyName = "In Call~Status~Meeting Password", Label = "Meeting Pass", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 5},
                  {Name = "Waiting for Host", PrettyName = "In Call~Indicators~Waiting for Host", Label = "Waiting for Host", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 7},
                  {Name = "In Waiting Room", PrettyName = "In Call~Indicators~In Waiting Room", Label = "In Waiting Room", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 8},
                  {Name = "In Call", PrettyName = "In Call~Indicators~In Call", Label = "In Call", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 9},
                  {Name = "In Call Presentation", PrettyName = "In Call~Indicators~In Presentation Mode", Label = "Presentation Mode", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 10},
                  {Name = "Meeting is Being Recorded", PrettyName = "In Call~Indicators~Meeting is Being Recorded", Label = "Meeting is Being Recorded", ControlType = "Indicator", ButtonType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 11},
                  
                  
                  
              }
          },
          {
              ["Name"] = "Start/Join",
              ["Depth"] = 9,
              ["Controls"] = {
                  {Name = "Start Local Presentation", PrettyName = "Start~Local Presentation", Label = "Start Presentation", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 1},
                  {Name = "Meet Now", PrettyName = "Start~Meet Now", Label = "Meet Now", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 2},
                  {Name = "Join Meeting ID", PrettyName = "Join~ID", Label = "ID", ControlType = "Text", PinStyle = "Both", UserPin = true, Size = Sizes.Text, GridPos = 4},
                  {Name = "Join Meeting Password", PrettyName = "Join~Password", Label = "Password", ControlType = "Text", PinStyle = "Both", UserPin = true, Size = Sizes.Text, GridPos = 5},
                  {Name = "Meeting Needs Password", PrettyName = "Join~Meeting Needs Password", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Position = (width-15) - Sizes.Text[1] - Sizes.LED[1], Size = Sizes.LED, GridPos = 5},
                  {Name = "Join Meeting", PrettyName = "Join~Join", Label = "Join Meeting", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 6},
                  {Name = "Caller Name", PrettyName = "Incoming~Caller Name", Label = "Caller Name", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 8},
                  {Name = "Incoming Call", PrettyName = "Incoming~Incoming Call", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Position = (width-15) - (Sizes.Button[1]*2) - Sizes.LED[1], Size = Sizes.LED, GridPos = 9},
                  {Name = "Call Accept", PrettyName = "Incoming~Accept", Legend = "Accept", Label = "Incoming Call", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - (Sizes.Button[1]*2), Size = Sizes.Button, GridPos = 9},
                  {Name = "Call Reject", PrettyName = "Incoming~Reject", Legend = "Reject", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 9},
              },
          },
          {
              ["Name"] = "In Call Settings",
              ["Depth"] = 2,
              ["Controls"] = {
                  {Name = "Mute User on Entry", PrettyName = "In Call~Indicators~Mute User on Entry", Label = "Mute on Entry", ControlType = "Indicator", ButtonType = "LED", PinStyle = "Output", UserPin = true, Position = (width-15) - (Sizes.Button[1]*2) - Sizes.LED[1], Size = Sizes.LED, GridPos = 1},
                  {Name = "Enable Mute on Entry", PrettyName = "In Call~Settings~Enable Mute on Entry", Legend = "Enable", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - (Sizes.Button[1]*2), Size = Sizes.Button, GridPos = 1},
                  {Name = "Disable Mute on Entry", PrettyName = "In Call~Settings~Disable Mute on Entry", Legend = "Disable", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - Sizes.Button[1], Size = Sizes.Button, GridPos = 1},
                  {Name = "Call Locked", PrettyName = "In Call~Indicators~Call Locked", Label = "Call Lock", ControlType = "Indicator", ButtonType = "LED", PinStyle = "Output", UserPin = true, Position = (width-15) - (Sizes.Button[1]*2) - Sizes.LED[1], Size = Sizes.LED, GridPos = 2},
                  {Name = "Lock Call", PrettyName = "In Call~Settings~Lock Call", Legend = "Lock", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - (Sizes.Button[1]*2), Size = Sizes.Button, GridPos = 2},
                  {Name = "Unlock Call", PrettyName = "In Call~Settings~Unlock Call", Legend = "Unlock", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - Sizes.Button[1], Size = Sizes.Button, GridPos = 2},
              },
          },
          {
              ["Name"] = "In Call Controls",
              ["Depth"] = 15,
              ["Controls"] = {
                  {Name = "Mute Mic", PrettyName = "In Call~Controls~Mute My Mic", Label = "Mute", Legend = "Mic", ControlType = "Button", ButtonType = "Toggle", PinStyle = "Both", UserPin = true, Position = (width-15) - (Sizes.Button[1]*2), Size = Sizes.Button, GridPos = 1},
                  {Name = "Mute Video", PrettyName = "In Call~Controls~Mute My Video", Legend = "Video", ControlType = "Button", ButtonType = "Toggle", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 1},
                  {Name = "Is Closed Caption Available", PrettyName = "In Call~Indicators~Is Closed Caption Available", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Position = (width-15) - Sizes.Button[1] - Sizes.LED[1], Size = Sizes.LED, Size = Sizes.LED, GridPos = 2},
                  {Name = "Closed Caption Visible", PrettyName = "In Call~Controls~Toggle Closed Caption", Legend = "Show", Label = "CC Available/Show", ControlType = "Button", ButtonType = "Toggle", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 2},
                  {Name = "Is Video Optimizable", PrettyName = "In Call~Indicators~Is Video Optimizable", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Position = (width-15) - Sizes.Button[1] - Sizes.LED[1], Size = Sizes.LED, GridPos = 3},
                  {Name = "Optimize Video", PrettyName = "In Call~Controls~Optimize Video", Label = "Optimize Video", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 3},
                  {Name = "Can Record", PrettyName = "In Call~Indicators~Can Record", Label = "Can Record", ControlType = "Indicator", ButtonType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 4},
                  {Name = "Email Required", PrettyName = "In Call~Indicators~Email Required", Label = "Recording Disabled (No Email)", ControlType = "Indicator", ButtonType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 5},
                  {Name = "Am I Recording", PrettyName = "In Call~Indicators~Am I Recording", Label = "Recording", ControlType = "Indicator", ButtonType = "LED", PinStyle = "Output", UserPin = true, Position = (width-15) - (Sizes.Button[1]*2) - Sizes.LED[1], Size = Sizes.LED, GridPos = 6},
                  {Name = "Start Recording", PrettyName = "In Call~Controls~Start Recording", Legend = "Start", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - (Sizes.Button[1]*2), Size = Sizes.Button, GridPos = 6},
                  {Name = "Stop Recording", PrettyName = "In Call~Controls~Stop Recording", Legend = "Stop", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - Sizes.Button[1], Size = Sizes.Button, GridPos = 6},
                  {Name = "Mute All", PrettyName = "In Call~Controls~Mute All", Legend = "Mute", Label = "Mute All", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - (Sizes.Button[1]*2), Size = Sizes.Button, GridPos = 7},
                  {Name = "Unmute All", PrettyName = "In Call~Controls~Unmute All", Legend = "Unmute", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - Sizes.Button[1], Size = Sizes.Button, GridPos = 7},
                  {Name = "Meeting Leave", PrettyName = "In Call~Controls~Leave Meeting", Legend = "Leave", Label = "Leave/End", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - (Sizes.Button[1]*2), Size = Sizes.Button, GridPos = 8},
                  {Name = "Meeting End", PrettyName = "In Call~Controls~End Meeting", Legend = "End", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 8},
                  {Name = "Layout Style",  ControlType = "Text", Style = "ListBox", Size = Sizes.ListBox, Width = "Full", GridPos = 10},
                  {Name = "Set View", PrettyName = "In Call~Controls~Set View", Label = "Set View", Legend = "Set", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 10},
              },
          },
          {
              ["Name"] = "Participants",
              ["Depth"] = 22,
              ["Controls"] = {
                  {Name = "Participant List", Label = "Participants List", ControlType = "Text", Style = "ListBox", Size = Sizes.ListBox, Width = "Full", GridPos = 1},
                  
                  --{Name = "Participant is Audio Muted", PrettyName = "In Call~Participants~Indicators~Audio Mute", Label = "Mic Mute", ControlType = "Indicator", ButtonType = "LED", PinStyle = "Output", UserPin = true, Position = (width-15) - (Sizes.Button[1]*2) - Sizes.LED[1], Size = Sizes.LED, GridPos = 7},
                  {Name = "Mute Participant Mic", PrettyName = "In Call~Participants~Mute Participant Mic", Label = "Mute Mic", Legend = "Mute", ControlType = "Button", ButtonType = "Toggle", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 7},
                  --{Name = "Unmute Participant Mic", PrettyName = "In Call~Participants~Unmute Participant Mic", Legend = "Unmute", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - Sizes.Button[1], Size = Sizes.Button, GridPos = 7},
                  
                  --{Name = "Participant is Video Muted", PrettyName = "In Call~Participants~Indicators~Video Mute", Label = "Video Mute", ControlType = "Indicator", ButtonType = "LED", PinStyle = "Output", UserPin = true, Position = (width-15) - (Sizes.Button[1]*2) - Sizes.LED[1], Size = Sizes.LED, GridPos = 8},
                  {Name = "Mute Participant Video", PrettyName = "In Call~Participants~Mute Participant Video", Label = "Mute Video", Legend = "Mute", ControlType = "Button", ButtonType = "Toggle", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 8},
                  --{Name = "Unmute Participant Video", PrettyName = "In Call~Participants~Unmute Participant Video", Legend = "Unmute", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - Sizes.Button[1], Size = Sizes.Button, GridPos = 8},

                  {Name = "Expel Participant", PrettyName = "In Call~Participants~Expel Participant", Legend = "Bye.", Label = "Expel", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 9},

                  {Name = "Pin Status 1", PrettyName = "In Call~Participants~Status~Screen 1 Pin", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 11},
                  {Name = "Pin to Screen 1", PrettyName = "In Call~Participants~Pin to Screen 1", Legend = "Pin", Label = "Screen 1", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - Sizes.Button[1] - Sizes.Text[1], Size = Sizes.Button, GridPos = 11},
                  {Name = "Pin Status 2", PrettyName = "In Call~Participants~Status~Screen 2 Pin", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 12},
                  {Name = "Pin to Screen 2", PrettyName = "In Call~Participants~Pin to Screen 2", Legend = "Pin", Label = "Screen 2", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - Sizes.Button[1] - Sizes.Text[1], Size = Sizes.Button, GridPos = 12},
                  {Name = "Pin Status 3", PrettyName = "In Call~Participants~Status~Screen 3 Pin", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 13},
                  {Name = "Pin to Screen 3", PrettyName = "In Call~Participants~Pin to Screen 3", Legend = "Pin", Label = "Screen 3", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - Sizes.Button[1] - Sizes.Text[1], Size = Sizes.Button, GridPos = 13},
                  {Name = "Pin Status 4", PrettyName = "In Call~Participants~Status~Screen 4 Pin", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 14},
                  {Name = "Pin to Screen 4", PrettyName = "In Call~Participants~Pin to Screen 4", Legend = "Pin", Label = "Screen 4", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - Sizes.Button[1] - Sizes.Text[1], Size = Sizes.Button, GridPos = 14},

                  {Name = "Unpin Participant", PrettyName = "In Call~Participants~Unpin", Legend = "Unpin", Label = "Unpin", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 15},
                  
                  {Name = "Spotlight Status", PrettyName = "In Call~Participants~Status~Spotlight ", Label = "Spotlight", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 17},
                  {Name = "Spotlight Active", PrettyName = "In Call~Participants~Indicators~Spotlight Active", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Position = (width-15) - Sizes.LED[1] - Sizes.Text[1], Size = Sizes.LED, GridPos = 17},
                  {Name = "Spotlight Participant", PrettyName = "In Call~Participants~Spotlight Participant", Label = "Spotlight Participant", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 18},
                  {Name = "Remove Spotlight", PrettyName = "In Call~Participants~Remove Spotlight", Label = "Remove Spotlight", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 19},

                  {Name = "Participant Can Record", PrettyName = "In Call~Participants~Indicators~Participant Can Record", Label = "Recording", ControlType = "Indicator", ButtonType = "LED", PinStyle = "Output", UserPin = true, Position = (width-15) - (Sizes.Button[1]*2) - Sizes.LED[1], Size = Sizes.LED, GridPos = 21},
                  {Name = "Allow Participant Record", PrettyName = "In Call~Participants~Indicators~Allow Participant Record", Legend = "Allow", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - (Sizes.Button[1]*2), Size = Sizes.Button, GridPos = 21},
                  {Name = "Disable Participant Record", PrettyName = "In Call~Participants~Indicators~Disable Participant Record", Legend = "Disable", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - Sizes.Button[1], Size = Sizes.Button, GridPos = 21},
                  {Name = "Participant is Recording", PrettyName = "In Call~Participants~Indicators~Participant is Recording", Label = "Participant is Recording", ControlType = "Indicator", ButtonType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 22},
                  

              },
          },
          {
              ["Name"] = "Participant's Cameras",
              ["Depth"] = 11,
              ["Controls"] = {
                  {Name = "Participant Cameras", Label = "Participant Cameras", ControlType = "Text", Style = "ListBox", Size = Sizes.ListBox, Width = "Full", GridPos = 1},
                  
                  {Name = "Request Control", PrettyName = "In Call~Participants~Camera Control~Request Control", Legend = "Gimme", Label = "Request Control", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 7},
                  {Name = "Camera Control 1", PrettyName = "In Call~Participants~Camera Control~Left", Label = "Pan", Legend = "Left", ControlType = "Button", ButtonType = "Momentary", PinStyle = "Both", UserPin = true, Position = (width-15) - (Sizes.Button[1]*2), Size = Sizes.Button, GridPos = 9},
                  {Name = "Camera Control 2", PrettyName = "In Call~Participants~Camera Control~Right", Legend = "Right", ControlType = "Button", ButtonType = "Momentary", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 9},
                  {Name = "Camera Control 3", PrettyName = "In Call~Participants~Camera Control~Up", Label = "Tilt", Legend = "Up", ControlType = "Button", ButtonType = "Momentary", PinStyle = "Both", UserPin = true, Position = (width-15) - (Sizes.Button[1]*2), Size = Sizes.Button, GridPos = 10},
                  {Name = "Camera Control 4", PrettyName = "In Call~Participants~Camera Control~Down", Legend = "Down", ControlType = "Button", ButtonType = "Momentary", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 10},
                  {Name = "Camera Zoom 1", PrettyName = "In Call~Participants~Camera Control~Zoom In", Label = "Zoom", Legend = "In", ControlType = "Button", ButtonType = "Momentary", PinStyle = "Both", UserPin = true, Position = (width-15) - (Sizes.Button[1]*2), Size = Sizes.Button, GridPos = 11},
                  {Name = "Camera Zoom 2", PrettyName = "In Call~Participants~Camera Control~Zoom Out", Legend = "Out", ControlType = "Button", ButtonType = "Momentary", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 11},
                  
              },
              
          },
          {
              ["Name"] = "Sharing",
              ["Depth"] = 28,
              ["Controls"] = {
                  {Name = "Sharing Status", PrettyName = "In Call~Sharing~Indicators~Status", Label = "Sharing Status", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Status, Width = "Full", GridPos = 1},
                  {Name = "Sharing WiFi Name", PrettyName = "In Call~Sharing~Details~WiFi Name", Label = "WiFi Name", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 4},
                  {Name = "Sharing Server Name", PrettyName = "In Call~Sharing~Details~Server Name", Label = "Server Name", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 5},
                  {Name = "Sharing Password", PrettyName = "In Call~Sharing~Details~Password", Label = "Password", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 6},
                  {Name = "Sharing Display State", PrettyName = "In Call~Sharing~Indicators~Display State", Label = "Display State", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 7},
                  {Name = "Sharing Paused", PrettyName = "In Call~Sharing~Indicators~Paused", Label = "Sharing Paused", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 8},

                  {Name = "Sharing Instructions Visible", PrettyName = "In Call~Sharing~Indicators~Instructions Visible", Label = "Instructions Visible", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 10},
                  {Name = "Sharing Instructions None", PrettyName = "In Call~Sharing~Instructions~Set None", Label = "Instructions", Legend = "None", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - (Sizes.Button[1]*3), Size = Sizes.Button, GridPos = 11},
                  {Name = "Sharing Instructions Laptop", PrettyName = "In Call~Sharing~Instructions~Set Laptop", Legend = "Laptop", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - (Sizes.Button[1]*2), Size = Sizes.Button, GridPos = 11},
                  {Name = "Sharing Instructions iOS", PrettyName = "In Call~Sharing~Instructions~Set iOS", Legend = "iOS", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 11},

                  {Name = "Is Airplay Sharing", PrettyName = "In Call~Sharing~Indicators~Airplay Sharing", Label = "Airplay Sharing", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 13},
                  {Name = "Is Black Magic Connected", PrettyName = "In Call~Sharing~Indicators~HDMI Connected", Label = "HDMI Connected", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 14},
                  {Name = "Is Black Magic Data Available", PrettyName = "In Call~Sharing~Indicators~HDMI Data Available", Label = "HDMI Data Available", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 15},
                  {Name = "Is Black Magic Sharing", PrettyName = "In Call~Sharing~Indicators~HDMI Sharing", Label = "HDMI Sharing", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 16},

                  {Name = "Presentation Pairing Code", PrettyName = "In Call~Sharing~Details~Direct Presentation Pairing Code", Label = "Pairing Code", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 18},
                  {Name = "Presentation Sharing Key", PrettyName = "In Call~Sharing~Details~Direct Presentation Sharing Key", Label = "Sharing Key", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 19},
                  {Name = "Is Direct Presentation Connected", PrettyName = "In Call~Sharing~Indicators~Direct Presentation Connected", Label = "Direct Presentation Connected", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 20},

                  {Name = "Start Sharing HDMI", PrettyName = "In Call~Sharing~Start Sharing HDMI", Legend = "Start", Label = "Sharing HDMI", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Position = (width-15) - (Sizes.Button[1]*2), Size = Sizes.Button, GridPos = 22},
                  {Name = "Stop Sharing HDMI", PrettyName = "In Call~Sharing~Stop Sharing HDMI", Legend = "Stop", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 22},
                  {Name = "Stop Local Sharing", PrettyName = "In Call~Sharing~Stop Local Sharing", Label = "Stop Local Sharing", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Both", UserPin = true, Size = Sizes.Button, GridPos = 23},

                  {Name = "Share Camera", PrettyName = "In Call~Sharing~Start Sharing Camera", Label = "Share Camera", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Output", UserPin = true, Size = Sizes.Button, GridPos = 28},
                  {Name = "Camera is Sharing", PrettyName = "In Call~Sharing~Indicators~Camera Sharing", Label = "Is Sharing", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 26},
                  {Name = "Camera Sharing Name", PrettyName = "In Call~Sharing~Indicators~Camera Name", Label = "Camera Name", ControlType = "Indicator", IndicatorType = "Text", PinStyle = "Output", UserPin = true, Size = Sizes.Text, GridPos = 25},
                  {Name = "Camera Sharing Can Control", PrettyName = "In Call~Sharing~Indicators~Camera Can Control", Label = "Can Control", ControlType = "Indicator", IndicatorType = "LED", PinStyle = "Output", UserPin = true, Size = Sizes.LED, GridPos = 27},

              },
              
          },
          {
              ["Name"] = "Zoom Events",
              ["Depth"] = 5,
              ["Controls"] = {
                  {Name = "Sharing Event Trigger", PrettyName = "Zoom Events~Sharing Event Trigger", Label = "Sharing Event", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Output", UserPin = true, Size = Sizes.Button, GridPos = 1},
                  {Name = "Call Ended by Host Trigger", PrettyName = "Zoom Events~Call Ended by Host Trigger", Label = "Host Ended", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Output", UserPin = true, Size = Sizes.Button, GridPos = 2},
                  {Name = "Call Ended by Host Mode", PrettyName = "Zoom Events~Call Ended by Host Mode", ControlType = "Text", Style = "ComboBox", PinStyle = "Both", UserPin = true, Size = Sizes.Text, Position = (width-15) - (Sizes.Button[1] + Sizes.Text[1]), GridPos = 2},
                  {Name = "Call Connect Trigger", PrettyName = "Zoom Events~Call Connect Trigger", Label = "Call Connected", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Output", UserPin = true, Size = Sizes.Button, GridPos = 3},
                  {Name = "Call Disconnect Trigger", PrettyName = "Zoom Events~Call Disconnect Trigger", Label = "Call Disconnected", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Output", UserPin = true, Size = Sizes.Button, GridPos = 4},
                  {Name = "Screen Sharing Disabled", PrettyName = "Zoom Events~Screen Sharing Disabled", Label = "Sharing Disabled", ControlType = "Button", ButtonType = "Trigger", PinStyle = "Output", UserPin = true, Size = Sizes.Button, GridPos = 5},
                  
              },
          },
      },
  }
}