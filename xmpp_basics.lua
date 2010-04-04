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

vlc = "http://localhost:8080/requests/status.xml"; -- http://git.videolan.org/?p=vlc.git;a=blob_plain;f=share/http/requests/readme;hb=HEAD
-- VLC commands
-- First those with no arguments, that have side effects (HTTP POST / XMPP IQ SET?)
-- these are a subset; see VLC docs for full listing.
local vlc_next = vlc .. "?command=pl_next";
local vlc_fullscreen = vlc .. "?command=fullscreen";
local vlc_toggle_pause = vlc .. "?command=pl_pause"; -- impact depends on current state
local vlc_stop = vlc .. "?command=pl_stop";
local vlc_prev = vlc .. "?command=pl_previous";
local vlc_empty_playlist = vlc .. "?command=pl_empty";
local vlc_fullscreen = vlc .. "command=fullscreen";
-- todo, investigate vlm_cmd.xml:

require "luarocks.require";
require "socket";
require "socket.http";
require "verse";
require "verse.client";
c = verse.new();
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

	  -- http://www.steve.org.uk/Software/lua-httpd/docs/examples.html
	  -- localhost:8080/requests/status.xml
	  -- http://git.videolan.org/?p=vlc.git;a=blob_plain;f=share/http/requests/readme;hb=HEAD
	  -- http://git.videolan.org/?p=vlc.git;a=tree;f=share/lua/http;h=5a3dd5b7b5cda0650f56c1785d12c228141113be;hb=HEAD
	  -- see also http://git.videolan.org/?p=vlc.git;a=blob_plain;f=share/lua/extensions/imdb.lua;hb=HEAD
	  -- b, h, c, e = socket.http.get("http://www.tecgraf.puc-rio.br/luasocket/http.html")

-- Note, Buttons markup needs to move from chat to IQ messages before we have a fixed protocol here:

	if cmd == "NOWP" then
--	if cmd == "PLUS" then
	  print "PLUS: received control msg, up/more/plus!"; -- fixme: decide on a mapping
          x=verse.iq({ type = "set", to = stanza.attr.from, from = stanza.attr.to });
	  local http = require("socket.http");
	  local res = http.request(vlc_next);
	  print("Tried to talk to vlc.", res);
          x:tag("query"):tag("ok");
	  c:send(x); -- assuming it went ok, if http failed or other evidence of oops, send a notok?
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

-- more VLC see http://wiki.foaf-project.org/w/Buttons/VLC
--    open "http://localhost:8080/requests/status.xml?command=setup test1 input file:///Users/danbri/Movies/BBC_LIFE/BBC.Life.s01e07.Hunters.And.Hunted.2009.HDTV.720p.x264.AC3.mkv"
--    open "http://localhost:8080/requests/status.xml?command=control test1 play"

