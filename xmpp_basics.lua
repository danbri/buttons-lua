#!/usr/bin/lua 

package.path = package.path .. ";../hg/verse/?.lua"; -- path to verse libraries
		-- see wiki.foaf-project.org/w/DanBri/LuaXMPP for setup tips
		-- XMPP Basics
		-- This Lua script shows use of Verse to connect to 
		-- set the appropriate account password, eg using: export BUTTONS_TEST=secrethere


-- set up XMPP basics
local jid, password = "buttons@foaf.tv", os.getenv ('BUTTONS_TEST');
local xmlns_buttons = "http://buttons.foaf.tv/";
local function set_version(self, version_info)
  	self.name = version_info.name;
      	self.version = version_info.version;
      	self.platform = version_info.platform;
end

require "verse"
require "verse.client"
c = verse.new()
c:add_plugin("sasl");
c:add_plugin("version");

-- Add some hooks for debugging
c:hook("opened", function () print("Stream opened!") end);
c:hook("closed", function () print("Stream closed!") end);
c:hook("stanza", function (stanza) 
  local name = stanza.name;
  if not (name == "iq")  then print("skipped [",name,"]"); return; end;
  print("IQ:\n", stanza);
  print("\n");
  local xmlns = stanza.tags[1] and stanza.tags[1].attr.xmlns;
  print("XMLNS is: ",xmlns,"\n");
  if (xmlns == xmlns_buttons) then
    print "BUTTONS!";
	-- <iq id='129400752' type='get' to='buttons@foaf.tv/34284939271270394140152524' 
	-- from='alice.notube@gmail.com/hardcoded6527FF4A'><query xmlns='http://buttons.foaf.tv/'>
	-- <button>NOWP</button></query></iq>
    local query = stanza:get_child("query", xmlns_buttons);
    print("Query elemnt: ",query);
    if query then
      local btn = query:get_child("button");
      if btn then
	cmd = btn:get_text()
        print("Button was: ",cmd);
	if cmd == "NOWP" then
	  print "NOWP: What's now playing?";
          x=verse.iq({ type = "set", to = stanza.attr.from, from = stanza.attr.to });
          x:tag("query"):tag("nothing_much");
	  c:send(x);
	end
      end
    end

    x=verse.iq({ type = "set", to = stanza.attr.from, from = stanza.attr.to });
    x:tag("query"):tag("ok");
    print("X: ",x);
  end
--  c:send(x);
  print("\n\n");
end);

-- This one prints all received data
c:hook("incoming-raw", print, 1000);

-- Print a message after authentication
c:hook("authentication-success", function () print("Logged in!"); end);
c:hook("authentication-failure", function (err) print("Failed to log in! Error: "..tostring(err.condition)); end);

-- Print a message and exit when disconnected
c:hook("disconnected", function () print("Disconnected!"); os.exit(); end);

-- Now, actually start the connection:
c:connect_client(jid, password);

-- Catch binding-success which is (currently) how you know when a stream is ready
c:hook("binding-success", function ()
	print("Stream ready!");
	c:send(verse.presence());
        print("Sent presence!");
	c.version:set{ name = "verse example client" };
	c:query_version(c.jid, function (v) print("I am using "..(v.name or "<unknown>")); end);

-- other experimental stuff here
--	print("IQ created?");
--	x = verse.iq({ type = "get", to = target_jid })
--	x:tag("query"):text("QWERTYUIOP");
--       print (x);
--	c:send(x); 
end);

print("Starting loop...")
verse.loop()

