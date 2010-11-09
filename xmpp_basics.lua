#!/usr/bin/lua 

--package.path = package.path .. ";../hg/verse/?.lua"; -- path to verse libraries


-- disco stuff from public domain code in riddim bot by Hubert Chathi <hubert@uhoreg.ca>
-- note: that hasn't been integrated yet

-- installation
-- pure lua dependencies are squished into 'verse.lua' nearby
-- install the luarocks package manager (apt-get install luarocks)
-- apt-get install libexpat1-dev for Expat headers
--  luarocks install luasocket
--  luarocks install luaexpat
-- todo: find out if luasocket and luaexpat (lxp) are available in VLC

require "luarocks.require";
require "socket";
require "socket.http";
require "verse";
require "verse.client";

require "sha1"
--local sha1 = require("util.hashes").sha1
local st = require "util.stanza"
local b64 = require("mime").b64
local http = require("socket.http");


-- see wiki.foaf-project.org/w/DanBri/LuaXMPP for setup tips
-- XMPP Basics
-- This Lua script shows use of Verse to connect to 
-- set the appropriate account password, eg using: export BUTTONS_TEST=secrethere


-- set up XMPP 
--local jid, password = "buttons@foaf.tv", os.getenv ('BUTTONS_TEST');

local jid, password = "bob.notube@gmail.com", os.getenv ('BUTTONS_TEST');
-- todo: check for nil password

local xmlns_buttons = "http://buttons.foaf.tv/";

vlc = "http://localhost:8080/requests/status.xml"; -- http://git.videolan.org/?p=vlc.git;a=blob_plain;f=share/http/requests/readme;hb=HEAD

vlc_playlist = "http://localhost:8080/requests/status.xml";

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

-- todo: investigate vlm_cmd.xml
-- here's how we get a screenshot
-- curl -s "http://localhost:8080/requests/status.xml?command=snapshot">/dev/null; ls ~/Desktop/*png
-- dumps an image/png into a dir (Desktop/ in my case), named something like vlcsnap-2010-04-04-22h19m54s229.png
-- todo: look at http://git.videolan.org/?p=vlc.git;a=blob_plain;f=share/lua/README.txt

c = verse.new();
c:add_plugin("sasl");
c:add_plugin("version");

--generates error    Attempt to close disconnected connection - possibly a bug
-- mattj knows about this, investigating..

--c:add_plugin("disco");
--c:add_disco_feature("http://buttons.foaf.tv/#!vlc_feature");
-- see also below when presence is sent

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

	  local plxml = http.request( vlc_playlist );
	  local plinfo = "playlist info.";

    words = {}
    for w in string.gfind(plxml, "name=\"([^\"]+)\" ro=\"") do
      print("XMLNAME: " , w);
      table.insert(words, w)
    end

          x=verse.iq({ type = "set", to = stanza.attr.from, from = stanza.attr.to });
          	x:tag("query")
		  :tag("html")
		   :tag("head")
 		    :tag("meta", { name="viewport", content="width=320"} )
                 :up()
		  :tag("body") 
		  :tag("div", { style="background: orange; height: 100%; font-family: Helvetica;"} )
		   :tag("h1")
		    :text("VLC media player")
		    :up()
		    :tag("hr")
		    :tag("h2")
		    :text("Now Playing...")
		    :up()
		    :tag("div")
		    :text("Current track: @@@ Next: ... Prev ....")
		    :up()	
		    :tag("hr")
		    :text("playlist");
			
	  c:send(x);
	end

	  -- http://www.steve.org.uk/Software/lua-httpd/docs/examples.html
	  -- localhost:8080/requests/status.xml
	  -- http://git.videolan.org/?p=vlc.git;a=blob_plain;f=share/http/requests/readme;hb=HEAD
	  -- http://git.videolan.org/?p=vlc.git;a=tree;f=share/lua/http;h=5a3dd5b7b5cda0650f56c1785d12c228141113be;hb=HEAD
	  -- see also http://git.videolan.org/?p=vlc.git;a=blob_plain;f=share/lua/extensions/imdb.lua;hb=HEAD
	  -- b, h, c, e = socket.http.get("http://www.tecgraf.puc-rio.br/luasocket/http.html")

-- Note, Buttons markup needs to move from chat to IQ messages before we have a fixed protocol here:

	if cmd == "RIGH" then
	  print "RIGH: received control msg!"; -- fixme: decide on a mapping
          x=verse.iq({ type = "set", to = stanza.attr.from, from = stanza.attr.to });
	  local http = require("socket.http");
	  local res = http.request(vlc_next);
	  print("Tried to talk to vlc.", res);
          x:tag("query"):tag("ok");
	  c:send(x); -- assuming it went ok, if http failed or other evidence of oops, send a notok?
	end

	if cmd == "LEFT" then
	  print "LEFT: received control msg!"; -- fixme: decide on a mapping
          x=verse.iq({ type = "set", to = stanza.attr.from, from = stanza.attr.to });
	  local http = require("socket.http");
	  local res = http.request(vlc_prev);
	  print("Tried to talk to vlc.", res);
          x:tag("query"):tag("ok");
	  c:send(x); -- assuming it went ok, if http failed or other evidence of oops, send a notok?
	end


	if cmd == "PLPZ" then
	  print "PLUS: received control msg, plpz!"; -- fixme: decide on a mapping
          x=verse.iq({ type = "set", to = stanza.attr.from, from = stanza.attr.to });
	  local res = http.request( vlc_toggle_pause );
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
c:hook("authentication-success", function () print("Logged in! (ready event, formerly authentication-success"); end);
c:hook("authentication-failure", function (err) print("Failed to log in! Error: "..tostring(err.condition)); end);

-- Print a message and exit when disconnected
c:hook("disconnected", function () print("Disconnected!"); os.exit(); end);

-- Now, actually start the connection:
c:connect_client(jid, password);

-- Catch binding-success which is (currently) how you know when a stream is ready
--xxxc:hook("binding-success", function ()
c:hook("ready", function ()
	print("Stream ready!");

	c:send(verse.presence());
-- this should work eventually, for disco:
--       c:send(verse.presence():add_child(conn:caps()));


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

-- c:disco();

verse.loop()

-- more VLC see http://wiki.foaf-project.org/w/Buttons/VLC
--    open "http://localhost:8080/requests/status.xml?command=setup test1 input file:///Users/danbri/Movies/BBC_LIFE/BBC.Life.s01e07.Hunters.And.Hunted.2009.HDTV.720p.x264.AC3.mkv"
--    open "http://localhost:8080/requests/status.xml?command=control test1 play"

-- notes from the DISCO code (copied from bot plugin)
--
-- Responds to service discovery queries (XEP-0030), and calculates the entity
-- capabilities hash (XEP-0115).

-- Fill the bot.disco.info.identities, bot.disco.info.features, and
-- bot.disco.items tables with the relevant disco data.  It comes pre-populated
-- to advertise support for disco#info, disco#items, and entity capabilities,
-- and to identify itself as Riddim.

-- If you want to advertise a node, add entries to the bot.disco.nodes table
-- with the relevant data.  The bot.disco.nodes table should have the same
-- format as bot.disco (without the nodes element).  The nodes are NOT
-- automatically added to the base disco items, so you will need to add them
-- yourself.

-- To property implement Entity Capabilities, you should make sure that you
-- send a "c" element within presence stanzas that are sent.  The correct "c"
-- element can be obtained by calling bot.caps() (or bot:caps()).





