package.preload['util.encodings'] = (function (...)
module "encodings"

-- this file compiled with the 'squish' utility from the external
-- verse and prosody packages. should be standalone now. 
-- see those packages for rights info etc. danbri@danbri.org

stringprep = {};

return _M;
end)
package.preload['util.logger'] = (function (...)
local print = print
local select, tostring = select, tostring;
module "logger"

local function format(format, ...)
	local n, maxn = 0, #arg;
	return (format:gsub("%%(.)", function (c) if c ~= "%" and n <= maxn then n = n + 1; return tostring(arg[n]); end end));
end

local function format(format, ...)
	local n, maxn = 0, select('#', ...);
	local arg = { ... };
	return (format:gsub("%%(.)", function (c) if n <= maxn then n = n + 1; return tostring(arg[n]); end end));
end

function init(name)
	return function (level, message, ...)
		print(level, format(message, ...));
	end
end

return _M;
end)
package.preload['util.xstanza'] = (function (...)
local stanza_mt = getmetatable(require "util.stanza".stanza());

local xmlns_stanzas = "urn:ietf:params:xml:ns:xmpp-stanzas";

function stanza_mt:get_error()
	local type, condition, text;
	
	local error_tag = self:get_child("error");
	if not error_tag then
		return nil, nil;
	end
	type = error_tag.attr.type;
	
	for child in error_tag:children() do
		if child.attr.xmlns == xmlns_stanzas then
			if child.name == "text" then
				text = child:get_text();
			else
				condition = child.name;
			end
			if condition and text then
				break;
			end
		end
	end
	return type, condition, text;
end
end)
package.preload['util.stanza'] = (function (...)
-- Prosody IM
-- Copyright (C) 2008-2010 Matthew Wild
-- Copyright (C) 2008-2010 Waqas Hussain
-- 
-- This project is MIT/X11 licensed. Please see the
-- COPYING file in the source package for more information.
--


local t_insert      =  table.insert;
local t_concat      =  table.concat;
local t_remove      =  table.remove;
local t_concat      =  table.concat;
local s_format      = string.format;
local s_match       =  string.match;
local tostring      =      tostring;
local setmetatable  =  setmetatable;
local getmetatable  =  getmetatable;
local pairs         =         pairs;
local ipairs        =        ipairs;
local type          =          type;
local next          =          next;
local print         =         print;
local unpack        =        unpack;
local s_gsub        =   string.gsub;
local s_char        =   string.char;
local s_find        =   string.find;
local os            =            os;

local do_pretty_printing = not os.getenv("WINDIR");
local getstyle, getstring;
if do_pretty_printing then
	local ok, termcolours = pcall(require, "util.termcolours");
	if ok then
		getstyle, getstring = termcolours.getstyle, termcolours.getstring;
	else
		do_pretty_printing = nil;
	end
end

local xmlns_stanzas = "urn:ietf:params:xml:ns:xmpp-stanzas";

module "stanza"

stanza_mt = { __type = "stanza" };
stanza_mt.__index = stanza_mt;

function stanza(name, attr)
	local stanza = { name = name, attr = attr or {}, tags = {}, last_add = {}};
	return setmetatable(stanza, stanza_mt);
end

function stanza_mt:query(xmlns)
	return self:tag("query", { xmlns = xmlns });
end

function stanza_mt:body(text, attr)
	return self:tag("body", attr):text(text);
end

function stanza_mt:tag(name, attrs)
	local s = stanza(name, attrs);
	(self.last_add[#self.last_add] or self):add_direct_child(s);
	t_insert(self.last_add, s);
	return self;
end

function stanza_mt:text(text)
	(self.last_add[#self.last_add] or self):add_direct_child(text);
	return self;
end

function stanza_mt:up()
	t_remove(self.last_add);
	return self;
end

function stanza_mt:reset()
	local last_add = self.last_add;
	for i = 1,#last_add do
		last_add[i] = nil;
	end
	return self;
end

function stanza_mt:add_direct_child(child)
	if type(child) == "table" then
		t_insert(self.tags, child);
	end
	t_insert(self, child);
end

function stanza_mt:add_child(child)
	(self.last_add[#self.last_add] or self):add_direct_child(child);
	return self;
end

function stanza_mt:get_child(name, xmlns)
	for _, child in ipairs(self.tags) do
		if (not name or child.name == name)
			and ((not xmlns and self.attr.xmlns == child.attr.xmlns)
				or child.attr.xmlns == xmlns) then
			
			return child;
		end
	end
end

function stanza_mt:child_with_name(name)
	for _, child in ipairs(self.tags) do
		if child.name == name then return child; end
	end
end

function stanza_mt:child_with_ns(ns)
	for _, child in ipairs(self.tags) do
		if child.attr.xmlns == ns then return child; end
	end
end

function stanza_mt:children()
	local i = 0;
	return function (a)
			i = i + 1
			local v = a[i]
			if v then return v; end
		end, self, i;
end
function stanza_mt:childtags()
	local i = 0;
	return function (a)
			i = i + 1
			local v = self.tags[i]
			if v then return v; end
		end, self.tags[1], i;
end

local xml_escape
do
	local escape_table = { ["'"] = "&apos;", ["\""] = "&quot;", ["<"] = "&lt;", [">"] = "&gt;", ["&"] = "&amp;" };
	function xml_escape(str) return (s_gsub(str, "['&<>\"]", escape_table)); end
	_M.xml_escape = xml_escape;
end

local function _dostring(t, buf, self, xml_escape, parentns)
	local nsid = 0;
	local name = t.name
	t_insert(buf, "<"..name);
	for k, v in pairs(t.attr) do
		if s_find(k, "\1", 1, true) then
			local ns, attrk = s_match(k, "^([^\1]*)\1?(.*)$");
			nsid = nsid + 1;
			t_insert(buf, " xmlns:ns"..nsid.."='"..xml_escape(ns).."' ".."ns"..nsid..":"..attrk.."='"..xml_escape(v).."'");
		elseif not(k == "xmlns" and v == parentns) then
			t_insert(buf, " "..k.."='"..xml_escape(v).."'");
		end
	end
	local len = #t;
	if len == 0 then
		t_insert(buf, "/>");
	else
		t_insert(buf, ">");
		for n=1,len do
			local child = t[n];
			if child.name then
				self(child, buf, self, xml_escape, t.attr.xmlns);
			else
				t_insert(buf, xml_escape(child));
			end
		end
		t_insert(buf, "</"..name..">");
	end
end
function stanza_mt.__tostring(t)
	local buf = {};
	_dostring(t, buf, _dostring, xml_escape, nil);
	return t_concat(buf);
end

function stanza_mt.top_tag(t)
	local attr_string = "";
	if t.attr then
		for k, v in pairs(t.attr) do if type(k) == "string" then attr_string = attr_string .. s_format(" %s='%s'", k, xml_escape(tostring(v))); end end
	end
	return s_format("<%s%s>", t.name, attr_string);
end

function stanza_mt.get_text(t)
	if #t.tags == 0 then
		return t_concat(t);
	end
end

function stanza_mt.get_error(stanza)
	local type, condition, text;
	
	local error_tag = stanza:get_child("error");
	if not error_tag then
		return nil, nil, nil;
	end
	type = error_tag.attr.type;
	
	for child in error_tag:children() do
		if child.attr.xmlns == xmlns_stanzas then
			if not text and child.name == "text" then
				text = child:get_text();
			elseif not condition then
				condition = child.name;
			end
			if condition and text then
				break;
			end
		end
	end
	return type, condition or "undefined-condition", text or "";
end

function stanza_mt.__add(s1, s2)
	return s1:add_direct_child(s2);
end


do
	local id = 0;
	function new_id()
		id = id + 1;
		return "lx"..id;
	end
end

function preserialize(stanza)
	local s = { name = stanza.name, attr = stanza.attr };
	for _, child in ipairs(stanza) do
		if type(child) == "table" then
			t_insert(s, preserialize(child));
		else
			t_insert(s, child);
		end
	end
	return s;
end

function deserialize(stanza)
	-- Set metatable
	if stanza then
		local attr = stanza.attr;
		for i=1,#attr do attr[i] = nil; end
		local attrx = {};
		for att in pairs(attr) do
			if s_find(att, "|", 1, true) and not s_find(att, "\1", 1, true) then
				local ns,na = s_match(att, "^([^|]+)|(.+)$");
				attrx[ns.."\1"..na] = attr[att];
				attr[att] = nil;
			end
		end
		for a,v in pairs(attrx) do
			attr[a] = v;
		end
		setmetatable(stanza, stanza_mt);
		for _, child in ipairs(stanza) do
			if type(child) == "table" then
				deserialize(child);
			end
		end
		if not stanza.tags then
			-- Rebuild tags
			local tags = {};
			for _, child in ipairs(stanza) do
				if type(child) == "table" then
					t_insert(tags, child);
				end
			end
			stanza.tags = tags;
			if not stanza.last_add then
				stanza.last_add = {};
			end
		end
	end
	
	return stanza;
end

function clone(stanza)
	local lookup_table = {};
	local function _copy(object)
		if type(object) ~= "table" then
			return object;
		elseif lookup_table[object] then
			return lookup_table[object];
		end
		local new_table = {};
		lookup_table[object] = new_table;
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value);
		end
		return setmetatable(new_table, getmetatable(object));
	end
	
	return _copy(stanza)
end

function message(attr, body)
	if not body then
		return stanza("message", attr);
	else
		return stanza("message", attr):tag("body"):text(body);
	end
end
function iq(attr)
	if attr and not attr.id then attr.id = new_id(); end
	return stanza("iq", attr or { id = new_id() });
end

function reply(orig)
	return stanza(orig.name, orig.attr and { to = orig.attr.from, from = orig.attr.to, id = orig.attr.id, type = ((orig.name == "iq" and "result") or orig.attr.type) });
end

do
	local xmpp_stanzas_attr = { xmlns = xmlns_stanzas };
	function error_reply(orig, type, condition, message)
		local t = reply(orig);
		t.attr.type = "error";
		t:tag("error", {type = type}) --COMPAT: Some day xmlns:stanzas goes here
			:tag(condition, xmpp_stanzas_attr):up();
		if (message) then t:tag("text", xmpp_stanzas_attr):text(message):up(); end
		return t; -- stanza ready for adding app-specific errors
	end
end

function presence(attr)
	return stanza("presence", attr);
end

if do_pretty_printing then
	local style_attrk = getstyle("yellow");
	local style_attrv = getstyle("red");
	local style_tagname = getstyle("red");
	local style_punc = getstyle("magenta");
	
	local attr_format = " "..getstring(style_attrk, "%s")..getstring(style_punc, "=")..getstring(style_attrv, "'%s'");
	local top_tag_format = getstring(style_punc, "<")..getstring(style_tagname, "%s").."%s"..getstring(style_punc, ">");
	--local tag_format = getstring(style_punc, "<")..getstring(style_tagname, "%s").."%s"..getstring(style_punc, ">").."%s"..getstring(style_punc, "</")..getstring(style_tagname, "%s")..getstring(style_punc, ">");
	local tag_format = top_tag_format.."%s"..getstring(style_punc, "</")..getstring(style_tagname, "%s")..getstring(style_punc, ">");
	function stanza_mt.pretty_print(t)
		local children_text = "";
		for n, child in ipairs(t) do
			if type(child) == "string" then
				children_text = children_text .. xml_escape(child);
			else
				children_text = children_text .. child:pretty_print();
			end
		end

		local attr_string = "";
		if t.attr then
			for k, v in pairs(t.attr) do if type(k) == "string" then attr_string = attr_string .. s_format(attr_format, k, tostring(v)); end end
		end
		return s_format(tag_format, t.name, attr_string, children_text, t.name);
	end
	
	function stanza_mt.pretty_top_tag(t)
		local attr_string = "";
		if t.attr then
			for k, v in pairs(t.attr) do if type(k) == "string" then attr_string = attr_string .. s_format(attr_format, k, tostring(v)); end end
		end
		return s_format(top_tag_format, t.name, attr_string);
	end
else
	-- Sorry, fresh out of colours for you guys ;)
	stanza_mt.pretty_print = stanza_mt.__tostring;
	stanza_mt.pretty_top_tag = stanza_mt.top_tag;
end

return _M;
end)
package.preload['util.timer'] = (function (...)
-- Prosody IM
-- Copyright (C) 2008-2010 Matthew Wild
-- Copyright (C) 2008-2010 Waqas Hussain
-- 
-- This project is MIT/X11 licensed. Please see the
-- COPYING file in the source package for more information.
--


local ns_addtimer = require "net.server".addtimer;
local event = require "net.server".event;
local event_base = require "net.server".event_base;

local get_time = os.time;
local t_insert = table.insert;
local t_remove = table.remove;
local ipairs, pairs = ipairs, pairs;
local type = type;

local data = {};
local new_data = {};

module "timer"

local _add_task;
if not event then
	function _add_task(delay, func)
		local current_time = get_time();
		delay = delay + current_time;
		if delay >= current_time then
			t_insert(new_data, {delay, func});
		else
			func();
		end
	end

	ns_addtimer(function()
		local current_time = get_time();
		if #new_data > 0 then
			for _, d in pairs(new_data) do
				t_insert(data, d);
			end
			new_data = {};
		end
		
		for i, d in pairs(data) do
			local t, func = d[1], d[2];
			if t <= current_time then
				data[i] = nil;
				local r = func(current_time);
				if type(r) == "number" then _add_task(r, func); end
			end
		end
	end);
else
	local EVENT_LEAVE = (event.core and event.core.LEAVE) or -1;
	function _add_task(delay, func)
		event_base:addevent(nil, 0, function ()
			local ret = func();
			if ret then
				return 0, ret;
			else
				return EVENT_LEAVE;
			end
		end
		, delay);
	end
end

add_task = _add_task;

return _M;
end)
package.preload['util.termcolours'] = (function (...)
-- Prosody IM
-- Copyright (C) 2008-2010 Matthew Wild
-- Copyright (C) 2008-2010 Waqas Hussain
-- 
-- This project is MIT/X11 licensed. Please see the
-- COPYING file in the source package for more information.
--


local t_concat, t_insert = table.concat, table.insert;
local char, format = string.char, string.format;
local ipairs = ipairs;
module "termcolours"

local stylemap = {
			reset = 0; bright = 1, dim = 2, underscore = 4, blink = 5, reverse = 7, hidden = 8;
			black = 30; red = 31; green = 32; yellow = 33; blue = 34; magenta = 35; cyan = 36; white = 37;
			["black background"] = 40; ["red background"] = 41; ["green background"] = 42; ["yellow background"] = 43; ["blue background"] = 44; ["magenta background"] = 45; ["cyan background"] = 46; ["white background"] = 47;
			bold = 1, dark = 2, underline = 4, underlined = 4, normal = 0;
		}

local fmt_string = char(0x1B).."[%sm%s"..char(0x1B).."[0m";
function getstring(style, text)
	if style then
		return format(fmt_string, style, text);
	else
		return text;
	end
end

function getstyle(...)
	local styles, result = { ... }, {};
	for i, style in ipairs(styles) do
		style = stylemap[style];
		if style then
			t_insert(result, style);
		end
	end
	return t_concat(result, ";");
end

return _M;
end)
package.preload['util.uuid'] = (function (...)
-- Prosody IM
-- Copyright (C) 2008-2010 Matthew Wild
-- Copyright (C) 2008-2010 Waqas Hussain
-- 
-- This project is MIT/X11 licensed. Please see the
-- COPYING file in the source package for more information.
--


local m_random = math.random;
local tostring = tostring;
local os_time = os.time;
local os_clock = os.clock;
local sha1 = require "util.hashes".sha1;

module "uuid"

local last_uniq_time = 0;
local function uniq_time()
	local new_uniq_time = os_time();
	if last_uniq_time >= new_uniq_time then new_uniq_time = last_uniq_time + 1; end
	last_uniq_time = new_uniq_time;
	return new_uniq_time;
end

local function new_random(x)
	return sha1(x..os_clock()..tostring({}), true);
end

local buffer = new_random(uniq_time());
local function _seed(x)
	buffer = new_random(buffer..x);
end
local function get_nibbles(n)
	if #buffer < n then seed(uniq_time()); end
	local r = buffer:sub(0, n);
	buffer = buffer:sub(n+1);
	return r;
end
local function get_twobits()
	return ("%x"):format(get_nibbles(1):byte() % 4 + 8);
end

function generate()
	-- generate RFC 4122 complaint UUIDs (version 4 - random)
	return get_nibbles(8).."-"..get_nibbles(4).."-4"..get_nibbles(3).."-"..(get_twobits())..get_nibbles(3).."-"..get_nibbles(12);
end
seed = _seed;

return _M;
end)
package.preload['net.server'] = (function (...)
-- 
-- server.lua by blastbeat of the luadch project
-- Re-used here under the MIT/X Consortium License
-- 
-- Modifications (C) 2008-2010 Matthew Wild, Waqas Hussain
--

-- // wrapping luadch stuff // --

local use = function( what )
	return _G[ what ]
end
local clean = function( tbl )
	for i, k in pairs( tbl ) do
		tbl[ i ] = nil
	end
end

local log, table_concat = require ("util.logger").init("socket"), table.concat;
local out_put = function (...) return log("debug", table_concat{...}); end
local out_error = function (...) return log("warn", table_concat{...}); end
local mem_free = collectgarbage

----------------------------------// DECLARATION //--

--// constants //--

local STAT_UNIT = 1 -- byte

--// lua functions //--

local type = use "type"
local pairs = use "pairs"
local ipairs = use "ipairs"
local tostring = use "tostring"
local collectgarbage = use "collectgarbage"

--// lua libs //--

local os = use "os"
local table = use "table"
local string = use "string"
local coroutine = use "coroutine"

--// lua lib methods //--

local os_time = os.time
local os_difftime = os.difftime
local table_concat = table.concat
local table_remove = table.remove
local string_len = string.len
local string_sub = string.sub
local coroutine_wrap = coroutine.wrap
local coroutine_yield = coroutine.yield

--// extern libs //--

local luasec = use "ssl"
local luasocket = use "socket" or require "socket"

--// extern lib methods //--

local ssl_wrap = ( luasec and luasec.wrap )
local socket_bind = luasocket.bind
local socket_sleep = luasocket.sleep
local socket_select = luasocket.select
local ssl_newcontext = ( luasec and luasec.newcontext )

--// functions //--

local id
local loop
local stats
local idfalse
local addtimer
local closeall
local addserver
local getserver
local wrapserver
local getsettings
local closesocket
local removesocket
local removeserver
local changetimeout
local wrapconnection
local changesettings

--// tables //--

local _server
local _readlist
local _timerlist
local _sendlist
local _socketlist
local _closelist
local _readtimes
local _writetimes

--// simple data types //--

local _
local _readlistlen
local _sendlistlen
local _timerlistlen

local _sendtraffic
local _readtraffic

local _selecttimeout
local _sleeptime

local _starttime
local _currenttime

local _maxsendlen
local _maxreadlen

local _checkinterval
local _sendtimeout
local _readtimeout

local _cleanqueue

local _timer

local _maxclientsperserver

----------------------------------// DEFINITION //--

_server = { } -- key = port, value = table; list of listening servers
_readlist = { } -- array with sockets to read from
_sendlist = { } -- arrary with sockets to write to
_timerlist = { } -- array of timer functions
_socketlist = { } -- key = socket, value = wrapped socket (handlers)
_readtimes = { } -- key = handler, value = timestamp of last data reading
_writetimes = { } -- key = handler, value = timestamp of last data writing/sending
_closelist = { } -- handlers to close

_readlistlen = 0 -- length of readlist
_sendlistlen = 0 -- length of sendlist
_timerlistlen = 0 -- lenght of timerlist

_sendtraffic = 0 -- some stats
_readtraffic = 0

_selecttimeout = 1 -- timeout of socket.select
_sleeptime = 0 -- time to wait at the end of every loop

_maxsendlen = 51000 * 1024 -- max len of send buffer
_maxreadlen = 25000 * 1024 -- max len of read buffer

_checkinterval = 1200000 -- interval in secs to check idle clients
_sendtimeout = 60000 -- allowed send idle time in secs
_readtimeout = 6 * 60 * 60 -- allowed read idle time in secs

_cleanqueue = false -- clean bufferqueue after using

_maxclientsperserver = 1000

_maxsslhandshake = 30 -- max handshake round-trips

----------------------------------// PRIVATE //--

wrapserver = function( listeners, socket, ip, serverport, pattern, sslctx, maxconnections ) -- this function wraps a server

	maxconnections = maxconnections or _maxclientsperserver

	local connections = 0

	local dispatch, disconnect = listeners.onincoming, listeners.ondisconnect

	local accept = socket.accept

	--// public methods of the object //--

	local handler = { }

	handler.shutdown = function( ) end

	handler.ssl = function( )
		return sslctx ~= nil
	end
	handler.sslctx = function( )
		return sslctx
	end
	handler.remove = function( )
		connections = connections - 1
	end
	handler.close = function( )
		for _, handler in pairs( _socketlist ) do
			if handler.serverport == serverport then
				handler.disconnect( handler, "server closed" )
				handler:close( true )
			end
		end
		socket:close( )
		_sendlistlen = removesocket( _sendlist, socket, _sendlistlen )
		_readlistlen = removesocket( _readlist, socket, _readlistlen )
		_socketlist[ socket ] = nil
		handler = nil
		socket = nil
		--mem_free( )
		out_put "server.lua: closed server handler and removed sockets from list"
	end
	handler.ip = function( )
		return ip
	end
	handler.serverport = function( )
		return serverport
	end
	handler.socket = function( )
		return socket
	end
	handler.readbuffer = function( )
		if connections > maxconnections then
			out_put( "server.lua: refused new client connection: server full" )
			return false
		end
		local client, err = accept( socket )	-- try to accept
		if client then
			local ip, clientport = client:getpeername( )
			client:settimeout( 0 )
			local handler, client, err = wrapconnection( handler, listeners, client, ip, serverport, clientport, pattern, sslctx ) -- wrap new client socket
			if err then -- error while wrapping ssl socket
				return false
			end
			connections = connections + 1
			out_put( "server.lua: accepted new client connection from ", tostring(ip), ":", tostring(clientport), " to ", tostring(serverport))
			return dispatch( handler )
		elseif err then -- maybe timeout or something else
			out_put( "server.lua: error with new client connection: ", tostring(err) )
			return false
		end
	end
	return handler
end

wrapconnection = function( server, listeners, socket, ip, serverport, clientport, pattern, sslctx ) -- this function wraps a client to a handler object

	socket:settimeout( 0 )

	--// local import of socket methods //--

	local send
	local receive
	local shutdown

	--// private closures of the object //--

	local ssl

	local dispatch = listeners.onincoming
	local status = listeners.onstatus
	local disconnect = listeners.ondisconnect

	local bufferqueue = { } -- buffer array
	local bufferqueuelen = 0	-- end of buffer array

	local toclose
	local fatalerror
	local needtls

	local bufferlen = 0

	local noread = false
	local nosend = false

	local sendtraffic, readtraffic = 0, 0

	local maxsendlen = _maxsendlen
	local maxreadlen = _maxreadlen

	--// public methods of the object //--

	local handler = bufferqueue -- saves a table ^_^

	handler.dispatch = function( )
		return dispatch
	end
	handler.disconnect = function( )
		return disconnect
	end
	handler.setlistener = function( self, listeners )
		dispatch = listeners.onincoming
		disconnect = listeners.ondisconnect
		status = listeners.onstatus
	end
	handler.getstats = function( )
		return readtraffic, sendtraffic
	end
	handler.ssl = function( )
		return ssl
	end
	handler.sslctx = function ( )
		return sslctx
	end
	handler.send = function( _, data, i, j )
		return send( socket, data, i, j )
	end
	handler.receive = function( pattern, prefix )
		return receive( socket, pattern, prefix )
	end
	handler.shutdown = function( pattern )
		return shutdown( socket, pattern )
	end
	handler.setoption = function (self, option, value)
		if socket.setoption then
			return socket:setoption(option, value);
		end
		return false, "setoption not implemented";
	end
	handler.close = function( self, forced )
		if not handler then return true; end
		_readlistlen = removesocket( _readlist, socket, _readlistlen )
		_readtimes[ handler ] = nil
		if bufferqueuelen ~= 0 then
			if not ( forced or fatalerror ) then
				handler.sendbuffer( )
				if bufferqueuelen ~= 0 then -- try again...
					if handler then
						handler.write = nil -- ... but no further writing allowed
					end
					toclose = true
					return false
				end
			else
				send( socket, table_concat( bufferqueue, "", 1, bufferqueuelen ), 1, bufferlen )	-- forced send
			end
		end
		if socket then
			_ = shutdown and shutdown( socket )
			socket:close( )
			_sendlistlen = removesocket( _sendlist, socket, _sendlistlen )
			_socketlist[ socket ] = nil
			socket = nil
		else
			out_put "server.lua: socket already closed"
		end
		if handler then
			_writetimes[ handler ] = nil
			_closelist[ handler ] = nil
			handler = nil
		end
	if server then
		server.remove( )
	end
		out_put "server.lua: closed client handler and removed socket from list"
		return true
	end
	handler.ip = function( )
		return ip
	end
	handler.serverport = function( )
		return serverport
	end
	handler.clientport = function( )
		return clientport
	end
	local write = function( self, data )
		bufferlen = bufferlen + string_len( data )
		if bufferlen > maxsendlen then
			_closelist[ handler ] = "send buffer exceeded"	 -- cannot close the client at the moment, have to wait to the end of the cycle
			handler.write = idfalse -- dont write anymore
			return false
		elseif socket and not _sendlist[ socket ] then
			_sendlistlen = addsocket(_sendlist, socket, _sendlistlen)
		end
		bufferqueuelen = bufferqueuelen + 1
		bufferqueue[ bufferqueuelen ] = data
		if handler then
			_writetimes[ handler ] = _writetimes[ handler ] or _currenttime
		end
		return true
	end
	handler.write = write
	handler.bufferqueue = function( self )
		return bufferqueue
	end
	handler.socket = function( self )
		return socket
	end
	handler.pattern = function( self, new )
		pattern = new or pattern
		return pattern
	end
	handler.set_send = function ( self, newsend )
		send = newsend or send
		return send
	end
	handler.bufferlen = function( self, readlen, sendlen )
		maxsendlen = sendlen or maxsendlen
		maxreadlen = readlen or maxreadlen
		return bufferlen, maxreadlen, maxsendlen
	end
	handler.lock_read = function (self, switch)
		if switch == true then
			local tmp = _readlistlen
			_readlistlen = removesocket( _readlist, socket, _readlistlen )
			_readtimes[ handler ] = nil
			if _readlistlen ~= tmp then
				noread = true
			end
		elseif switch == false then
			if noread then
				noread = false
				_readlistlen = addsocket(_readlist, socket, _readlistlen)
				_readtimes[ handler ] = _currenttime
			end
		end
		return noread
	end
	handler.lock = function( self, switch )
		handler.lock_read (switch)
		if switch == true then
			handler.write = idfalse
			local tmp = _sendlistlen
			_sendlistlen = removesocket( _sendlist, socket, _sendlistlen )
			_writetimes[ handler ] = nil
			if _sendlistlen ~= tmp then
				nosend = true
			end
		elseif switch == false then
			handler.write = write
			if nosend then
				nosend = false
				write( "" )
			end
		end
		return noread, nosend
	end
	local _readbuffer = function( ) -- this function reads data
		local buffer, err, part = receive( socket, pattern )	-- receive buffer with "pattern"
		if not err or (err == "wantread" or err == "timeout") or (part and string_len(part) > 0) then -- received something
			local buffer = buffer or part or ""
			local len = string_len( buffer )
			if len > maxreadlen then
				disconnect( handler, "receive buffer exceeded" )
				handler:close( true )
				return false
			end
			local count = len * STAT_UNIT
			readtraffic = readtraffic + count
			_readtraffic = _readtraffic + count
			_readtimes[ handler ] = _currenttime
			--out_put( "server.lua: read data '", buffer:gsub("[^%w%p ]", "."), "', error: ", err )
			return dispatch( handler, buffer, err )
		else	-- connections was closed or fatal error
			out_put( "server.lua: client ", tostring(ip), ":", tostring(clientport), " read error: ", tostring(err) )
			fatalerror = true
			disconnect( handler, err )
		_ = handler and handler:close( )
			return false
		end
	end
	local _sendbuffer = function( ) -- this function sends data
		local succ, err, byte, buffer, count;
		local count;
		if socket then
			buffer = table_concat( bufferqueue, "", 1, bufferqueuelen )
			succ, err, byte = send( socket, buffer, 1, bufferlen )
			count = ( succ or byte or 0 ) * STAT_UNIT
			sendtraffic = sendtraffic + count
			_sendtraffic = _sendtraffic + count
			_ = _cleanqueue and clean( bufferqueue )
			--out_put( "server.lua: sended '", buffer, "', bytes: ", tostring(succ), ", error: ", tostring(err), ", part: ", tostring(byte), ", to: ", tostring(ip), ":", tostring(clientport) )
		else
			succ, err, count = false, "closed", 0;
		end
		if succ then	-- sending succesful
			bufferqueuelen = 0
			bufferlen = 0
			_sendlistlen = removesocket( _sendlist, socket, _sendlistlen ) -- delete socket from writelist
			_ = needtls and handler:starttls(nil, true)
			_writetimes[ handler ] = nil
			_ = toclose and handler:close( )
			return true
		elseif byte and ( err == "timeout" or err == "wantwrite" ) then -- want write
			buffer = string_sub( buffer, byte + 1, bufferlen ) -- new buffer
			bufferqueue[ 1 ] = buffer	 -- insert new buffer in queue
			bufferqueuelen = 1
			bufferlen = bufferlen - byte
			_writetimes[ handler ] = _currenttime
			return true
		else	-- connection was closed during sending or fatal error
			out_put( "server.lua: client ", tostring(ip), ":", tostring(clientport), " write error: ", tostring(err) )
			fatalerror = true
			disconnect( handler, err )
			_ = handler and handler:close( )
			return false
		end
	end

	-- Set the sslctx
	local handshake;
	function handler.set_sslctx(self, new_sslctx)
		ssl = true
		sslctx = new_sslctx;
		local wrote
		local read
		handshake = coroutine_wrap( function( client ) -- create handshake coroutine
				local err
				for i = 1, _maxsslhandshake do
					_sendlistlen = ( wrote and removesocket( _sendlist, client, _sendlistlen ) ) or _sendlistlen
					_readlistlen = ( read and removesocket( _readlist, client, _readlistlen ) ) or _readlistlen
					read, wrote = nil, nil
					_, err = client:dohandshake( )
					if not err then
						out_put( "server.lua: ssl handshake done" )
						handler.readbuffer = _readbuffer	-- when handshake is done, replace the handshake function with regular functions
						handler.sendbuffer = _sendbuffer
						_ = status and status( handler, "ssl-handshake-complete" )
						_readlistlen = addsocket(_readlist, client, _readlistlen)
						return true
					else
						out_put( "server.lua: error during ssl handshake: ", tostring(err) )
						if err == "wantwrite" and not wrote then
							_sendlistlen = addsocket(_sendlist, client, _sendlistlen)
							wrote = true
						elseif err == "wantread" and not read then
							_readlistlen = addsocket(_readlist, client, _readlistlen)
							read = true
						else
							break;
						end
						--coroutine_yield( handler, nil, err )	 -- handshake not finished
						coroutine_yield( )
					end
				end
				disconnect( handler, "ssl handshake failed" )
				_ = handler and handler:close( true )	 -- forced disconnect
				return false	-- handshake failed
			end
		)
	end
	if luasec then
		if sslctx then -- ssl?
			handler:set_sslctx(sslctx);
			out_put("server.lua: ", "starting ssl handshake")
			local err
			socket, err = ssl_wrap( socket, sslctx )	-- wrap socket
			if err then
				out_put( "server.lua: ssl error: ", tostring(err) )
				--mem_free( )
				return nil, nil, err	-- fatal error
			end
			socket:settimeout( 0 )
			handler.readbuffer = handshake
			handler.sendbuffer = handshake
			handshake( socket ) -- do handshake
			if not socket then
				return nil, nil, "ssl handshake failed";
			end
		else
			local sslctx;
			handler.starttls = function( self, _sslctx, now )
				if _sslctx then
					sslctx = _sslctx;
					handler:set_sslctx(sslctx);
				end
				if not now then
					out_put "server.lua: we need to do tls, but delaying until later"
					needtls = true
					return
				end
				out_put( "server.lua: attempting to start tls on " .. tostring( socket ) )
				local oldsocket, err = socket
				socket, err = ssl_wrap( socket, sslctx )	-- wrap socket
				--out_put( "server.lua: sslwrapped socket is " .. tostring( socket ) )
				if err then
					out_put( "server.lua: error while starting tls on client: ", tostring(err) )
					return nil, err -- fatal error
				end

				socket:settimeout( 0 )
	
				-- add the new socket to our system
	
				send = socket.send
				receive = socket.receive
				shutdown = id

				_socketlist[ socket ] = handler
				_readlistlen = addsocket(_readlist, socket, _readlistlen)

				-- remove traces of the old socket

				_readlistlen = removesocket( _readlist, oldsocket, _readlistlen )
				_sendlistlen = removesocket( _sendlist, oldsocket, _sendlistlen )
				_socketlist[ oldsocket ] = nil

				handler.starttls = nil
				needtls = nil

				-- Secure now
				ssl = true

				handler.readbuffer = handshake
				handler.sendbuffer = handshake
				handshake( socket ) -- do handshake
			end
			handler.readbuffer = _readbuffer
			handler.sendbuffer = _sendbuffer
		end
	else
		handler.readbuffer = _readbuffer
		handler.sendbuffer = _sendbuffer
	end
	send = socket.send
	receive = socket.receive
	shutdown = ( ssl and id ) or socket.shutdown

	_socketlist[ socket ] = handler
	_readlistlen = addsocket(_readlist, socket, _readlistlen)

	return handler, socket
end

id = function( )
end

idfalse = function( )
	return false
end

addsocket = function( list, socket, len )
	if not list[ socket ] then
		len = len + 1
		list[ len ] = socket
		list[ socket ] = len
	end
	return len;
end

removesocket = function( list, socket, len )	-- this function removes sockets from a list ( copied from copas )
	local pos = list[ socket ]
	if pos then
		list[ socket ] = nil
		local last = list[ len ]
		list[ len ] = nil
		if last ~= socket then
			list[ last ] = pos
			list[ pos ] = last
		end
		return len - 1
	end
	return len
end

closesocket = function( socket )
	_sendlistlen = removesocket( _sendlist, socket, _sendlistlen )
	_readlistlen = removesocket( _readlist, socket, _readlistlen )
	_socketlist[ socket ] = nil
	socket:close( )
	--mem_free( )
end

----------------------------------// PUBLIC //--

addserver = function( addr, port, listeners, pattern, sslctx ) -- this function provides a way for other scripts to reg a server
	local err
	if type( listeners ) ~= "table" then
		err = "invalid listener table"
	end
	if not type( port ) == "number" or not ( port >= 0 and port <= 65535 ) then
		err = "invalid port"
	elseif _server[ port ] then
		err = "listeners on port '" .. port .. "' already exist"
	elseif sslctx and not luasec then
		err = "luasec not found"
	end
	if err then
		out_error( "server.lua, port ", port, ": ", err )
		return nil, err
	end
	addr = addr or "*"
	local server, err = socket_bind( addr, port )
	if err then
		out_error( "server.lua, port ", port, ": ", err )
		return nil, err
	end
	local handler, err = wrapserver( listeners, server, addr, port, pattern, sslctx, _maxclientsperserver ) -- wrap new server socket
	if not handler then
		server:close( )
		return nil, err
	end
	server:settimeout( 0 )
	_readlistlen = addsocket(_readlist, server, _readlistlen)
	_server[ port ] = handler
	_socketlist[ server ] = handler
	out_put( "server.lua: new "..(sslctx and "ssl " or "").."server listener on '", addr, ":", port, "'" )
	return handler
end

getserver = function ( port )
	return _server[ port ];
end

removeserver = function( port )
	local handler = _server[ port ]
	if not handler then
		return nil, "no server found on port '" .. tostring( port ) .. "'"
	end
	handler:close( )
	_server[ port ] = nil
	return true
end

closeall = function( )
	for _, handler in pairs( _socketlist ) do
		handler:close( )
		_socketlist[ _ ] = nil
	end
	_readlistlen = 0
	_sendlistlen = 0
	_timerlistlen = 0
	_server = { }
	_readlist = { }
	_sendlist = { }
	_timerlist = { }
	_socketlist = { }
	--mem_free( )
end

getsettings = function( )
	return	_selecttimeout, _sleeptime, _maxsendlen, _maxreadlen, _checkinterval, _sendtimeout, _readtimeout, _cleanqueue, _maxclientsperserver, _maxsslhandshake
end

changesettings = function( new )
	if type( new ) ~= "table" then
		return nil, "invalid settings table"
	end
	_selecttimeout = tonumber( new.timeout ) or _selecttimeout
	_sleeptime = tonumber( new.sleeptime ) or _sleeptime
	_maxsendlen = tonumber( new.maxsendlen ) or _maxsendlen
	_maxreadlen = tonumber( new.maxreadlen ) or _maxreadlen
	_checkinterval = tonumber( new.checkinterval ) or _checkinterval
	_sendtimeout = tonumber( new.sendtimeout ) or _sendtimeout
	_readtimeout = tonumber( new.readtimeout ) or _readtimeout
	_cleanqueue = new.cleanqueue
	_maxclientsperserver = new._maxclientsperserver or _maxclientsperserver
	_maxsslhandshake = new._maxsslhandshake or _maxsslhandshake
	return true
end

addtimer = function( listener )
	if type( listener ) ~= "function" then
		return nil, "invalid listener function"
	end
	_timerlistlen = _timerlistlen + 1
	_timerlist[ _timerlistlen ] = listener
	return true
end

stats = function( )
	return _readtraffic, _sendtraffic, _readlistlen, _sendlistlen, _timerlistlen
end

local dontstop = true; -- thinking about tomorrow, ...

setquitting = function (quit)
	dontstop = not quit;
	return;
end

loop = function( ) -- this is the main loop of the program
	while dontstop do
		local read, write, err = socket_select( _readlist, _sendlist, _selecttimeout )
		for i, socket in ipairs( write ) do -- send data waiting in writequeues
			local handler = _socketlist[ socket ]
			if handler then
				handler.sendbuffer( )
			else
				closesocket( socket )
				out_put "server.lua: found no handler and closed socket (writelist)"	-- this should not happen
			end
		end
		for i, socket in ipairs( read ) do -- receive data
			local handler = _socketlist[ socket ]
			if handler then
				handler.readbuffer( )
			else
				closesocket( socket )
				out_put "server.lua: found no handler and closed socket (readlist)" -- this can happen
			end
		end
		for handler, err in pairs( _closelist ) do
			handler.disconnect( )( handler, err )
			handler:close( true )	 -- forced disconnect
		end
		clean( _closelist )
		_currenttime = os_time( )
		if os_difftime( _currenttime - _timer ) >= 1 then
			for i = 1, _timerlistlen do
				_timerlist[ i ]( _currenttime ) -- fire timers
			end
			_timer = _currenttime
		end
		socket_sleep( _sleeptime ) -- wait some time
		--collectgarbage( )
	end
	return "quitting"
end

local function get_backend()
	return "select";
end

--// EXPERIMENTAL //--

local wrapclient = function( socket, ip, serverport, listeners, pattern, sslctx )
	local handler = wrapconnection( nil, listeners, socket, ip, serverport, "clientport", pattern, sslctx )
	_socketlist[ socket ] = handler
	_sendlistlen = addsocket(_sendlist, socket, _sendlistlen)
	return handler, socket
end

local addclient = function( address, port, listeners, pattern, sslctx )
	local client, err = luasocket.tcp( )
	if err then
		return nil, err
	end
	client:settimeout( 0 )
	_, err = client:connect( address, port )
	if err then -- try again
		local handler = wrapclient( client, address, port, listeners )
	else
		wrapconnection( nil, listeners, client, address, port, "clientport", pattern, sslctx )
	end
end

--// EXPERIMENTAL //--

----------------------------------// BEGIN //--

use "setmetatable" ( _socketlist, { __mode = "k" } )
use "setmetatable" ( _readtimes, { __mode = "k" } )
use "setmetatable" ( _writetimes, { __mode = "k" } )

_timer = os_time( )
_starttime = os_time( )

addtimer( function( )
		local difftime = os_difftime( _currenttime - _starttime )
		if difftime > _checkinterval then
			_starttime = _currenttime
			for handler, timestamp in pairs( _writetimes ) do
				if os_difftime( _currenttime - timestamp ) > _sendtimeout then
					--_writetimes[ handler ] = nil
					handler.disconnect( )( handler, "send timeout" )
					handler:close( true )	 -- forced disconnect
				end
			end
			for handler, timestamp in pairs( _readtimes ) do
				if os_difftime( _currenttime - timestamp ) > _readtimeout then
					--_readtimes[ handler ] = nil
					handler.disconnect( )( handler, "read timeout" )
					handler:close( )	-- forced disconnect?
				end
			end
		end
	end
)

local function setlogger(new_logger)
	local old_logger = log;
	if new_logger then
		log = new_logger;
	end
	return old_logger;
end

----------------------------------// PUBLIC INTERFACE //--

return {

	addclient = addclient,
	wrapclient = wrapclient,
	
	loop = loop,
	stats = stats,
	closeall = closeall,
	addtimer = addtimer,
	addserver = addserver,
	getserver = getserver,
	setlogger = setlogger,
	getsettings = getsettings,
	setquitting = setquitting,
	removeserver = removeserver,
	get_backend = get_backend,
	changesettings = changesettings,
}
end)
package.preload['core.xmlhandlers'] = (function (...)
-- Prosody IM
-- Copyright (C) 2008-2010 Matthew Wild
-- Copyright (C) 2008-2010 Waqas Hussain
-- 
-- This project is MIT/X11 licensed. Please see the
-- COPYING file in the source package for more information.
--



require "util.stanza"

local st = stanza;
local tostring = tostring;
local t_insert = table.insert;
local t_concat = table.concat;

local default_log = require "util.logger".init("xmlhandlers");

local error = error;

module "xmlhandlers"

local ns_prefixes = {
	["http://www.w3.org/XML/1998/namespace"] = "xml";
};

local xmlns_streams = "http://etherx.jabber.org/streams";

local ns_separator = "\1";
local ns_pattern = "^([^"..ns_separator.."]*)"..ns_separator.."?(.*)$";

function init_xmlhandlers(session, stream_callbacks)
	local chardata = {};
	local xml_handlers = {};
	local log = session.log or default_log;
	
	local cb_streamopened = stream_callbacks.streamopened;
	local cb_streamclosed = stream_callbacks.streamclosed;
	local cb_error = stream_callbacks.error or function(session, e) error("XML stream error: "..tostring(e)); end;
	local cb_handlestanza = stream_callbacks.handlestanza;
	
	local stream_ns = stream_callbacks.stream_ns or xmlns_streams;
	local stream_tag = stream_ns..ns_separator..(stream_callbacks.stream_tag or "stream");
	local stream_error_tag = stream_ns..ns_separator..(stream_callbacks.error_tag or "error");
	
	local stream_default_ns = stream_callbacks.default_ns;
	
	local stanza;
	function xml_handlers:StartElement(tagname, attr)
		if stanza and #chardata > 0 then
			-- We have some character data in the buffer
			stanza:text(t_concat(chardata));
			chardata = {};
		end
		local curr_ns,name = tagname:match(ns_pattern);
		if name == "" then
			curr_ns, name = "", curr_ns;
		end

		if curr_ns ~= stream_default_ns then
			attr.xmlns = curr_ns;
		end
		
		-- FIXME !!!!!
		for i=1,#attr do
			local k = attr[i];
			attr[i] = nil;
			local ns, nm = k:match(ns_pattern);
			if nm ~= "" then
				ns = ns_prefixes[ns]; 
				if ns then 
					attr[ns..":"..nm] = attr[k];
					attr[k] = nil;
				end
			end
		end
		
		if not stanza then --if we are not currently inside a stanza
			if session.notopen then
				if tagname == stream_tag then
					if cb_streamopened then
						cb_streamopened(session, attr);
					end
				else
					-- Garbage before stream?
					cb_error(session, "no-stream");
				end
				return;
			end
			if curr_ns == "jabber:client" and name ~= "iq" and name ~= "presence" and name ~= "message" then
				cb_error(session, "invalid-top-level-element");
			end
			
			stanza = st.stanza(name, attr);
		else -- we are inside a stanza, so add a tag
			attr.xmlns = nil;
			if curr_ns ~= stream_default_ns then
				attr.xmlns = curr_ns;
			end
			stanza:tag(name, attr);
		end
	end
	function xml_handlers:CharacterData(data)
		if stanza then
			t_insert(chardata, data);
		end
	end
	function xml_handlers:EndElement(tagname)
		if stanza then
			if #chardata > 0 then
				-- We have some character data in the buffer
				stanza:text(t_concat(chardata));
				chardata = {};
			end
			-- Complete stanza
			if #stanza.last_add == 0 then
				if tagname ~= stream_error_tag then
					cb_handlestanza(session, stanza);
				else
					cb_error(session, "stream-error", stanza);
				end
				stanza = nil;
			else
				stanza:up();
			end
		else
			if tagname == stream_tag then
				if cb_streamclosed then
					cb_streamclosed(session);
				end
			else
				local curr_ns,name = tagname:match(ns_pattern);
				if name == "" then
					curr_ns, name = "", curr_ns;
				end
				cb_error(session, "parse-error", "unexpected-element-close", name);
			end
			stanza, chardata = nil, {};
		end
	end
	return xml_handlers;
end

return init_xmlhandlers;
end)
package.preload['util.jid'] = (function (...)
-- Prosody IM
-- Copyright (C) 2008-2010 Matthew Wild
-- Copyright (C) 2008-2010 Waqas Hussain
-- 
-- This project is MIT/X11 licensed. Please see the
-- COPYING file in the source package for more information.
--



local match = string.match;
local nodeprep = require "util.encodings".stringprep.nodeprep;
local nameprep = require "util.encodings".stringprep.nameprep;
local resourceprep = require "util.encodings".stringprep.resourceprep;

module "jid"

local function _split(jid)
	if not jid then return; end
	local node, nodepos = match(jid, "^([^@]+)@()");
	local host, hostpos = match(jid, "^([^@/]+)()", nodepos)
	if node and not host then return nil, nil, nil; end
	local resource = match(jid, "^/(.+)$", hostpos);
	if (not host) or ((not resource) and #jid >= hostpos) then return nil, nil, nil; end
	return node, host, resource;
end
split = _split;

function bare(jid)
	local node, host = _split(jid);
	if node and host then
		return node.."@"..host;
	end
	return host;
end

local function _prepped_split(jid)
	local node, host, resource = _split(jid);
	if host then
		host = nameprep(host);
		if not host then return; end
		if node then
			node = nodeprep(node);
			if not node then return; end
		end
		if resource then
			resource = resourceprep(resource);
			if not resource then return; end
		end
		return node, host, resource;
	end
end
prepped_split = _prepped_split;

function prep(jid)
	local node, host, resource = _prepped_split(jid);
	if host then
		if node then
			host = node .. "@" .. host;
		end
		if resource then
			host = host .. "/" .. resource;
		end
	end
	return host;
end

function join(node, host, resource)
	if node and host and resource then
		return node.."@"..host.."/"..resource;
	elseif node and host then
		return node.."@"..host;
	elseif host and resource then
		return host.."/"..resource;
	elseif host then
		return host;
	end
	return nil; -- Invalid JID
end

return _M;
end)
package.preload['util.events'] = (function (...)
-- Prosody IM
-- Copyright (C) 2008-2010 Matthew Wild
-- Copyright (C) 2008-2010 Waqas Hussain
-- 
-- This project is MIT/X11 licensed. Please see the
-- COPYING file in the source package for more information.
--


local ipairs = ipairs;
local pairs = pairs;
local t_insert = table.insert;
local t_sort = table.sort;
local select = select;

module "events"

function new()
	local dispatchers = {};
	local handlers = {};
	local event_map = {};
	local function _rebuild_index(event) -- TODO optimize index rebuilding
		local _handlers = event_map[event];
		local index = handlers[event];
		if index then
			for i=#index,1,-1 do index[i] = nil; end
		else index = {}; handlers[event] = index; end
		for handler in pairs(_handlers) do
			t_insert(index, handler);
		end
		t_sort(index, function(a, b) return _handlers[a] > _handlers[b]; end);
	end;
	local function add_handler(event, handler, priority)
		local map = event_map[event];
		if map then
			map[handler] = priority or 0;
		else
			map = {[handler] = priority or 0};
			event_map[event] = map;
		end
		_rebuild_index(event);
	end;
	local function remove_handler(event, handler)
		local map = event_map[event];
		if map then
			map[handler] = nil;
			_rebuild_index(event);
		end
	end;
	local function add_handlers(handlers)
		for event, handler in pairs(handlers) do
			add_handler(event, handler);
		end
	end;
	local function remove_handlers(handlers)
		for event, handler in pairs(handlers) do
			remove_handler(event, handler);
		end
	end;
	local function _create_dispatcher(event) -- FIXME duplicate code in fire_event
		local h = handlers[event];
		if not h then h = {}; handlers[event] = h; end
		local dispatcher = function(...)
			for i=1,#h do
				local ret = h[i](...);
				if ret ~= nil then return ret; end
			end
		end;
		dispatchers[event] = dispatcher;
		return dispatcher;
	end;
	local function get_dispatcher(event)
		return dispatchers[event] or _create_dispatcher(event);
	end;
	local function fire_event(event, ...) -- FIXME duplicates dispatcher code
		local h = handlers[event];
		if h then
			for i=1,#h do
				local ret = h[i](...);
				if ret ~= nil then return ret; end
			end
		end
	end;
	local function get_named_arg_dispatcher(event, ...)
		local dispatcher = get_dispatcher(event);
		local keys = {...};
		local data = {};
		return function(...)
			for i, key in ipairs(keys) do data[key] = select(i, ...); end
			dispatcher(data);
		end;
	end;
	return {
		add_handler = add_handler;
		remove_handler = remove_handler;
		add_plugin = add_plugin;
		remove_plugin = remove_plugin;
		get_dispatcher = get_dispatcher;
		fire_event = fire_event;
		get_named_arg_dispatcher = get_named_arg_dispatcher;
		_dispatchers = dispatchers;
		_handlers = handlers;
		_event_map = event_map;
	};
end

return _M;
end)
package.preload['verse.plugins.sasl'] = (function (...)
local st = require "util.stanza";
local stx = require "util.xstanza";
local base64 = require "mime".b64;
local xmlns_sasl = "urn:ietf:params:xml:ns:xmpp-sasl";

function verse.plugins.sasl(stream)
	local function handle_features(features_stanza)
		if stream.authenticated then return; end
		stream:debug("Authenticating with SASL...");
		local initial_data = base64("\0"..stream.username.."\0"..stream.password);
	
		--stream.sasl_state, initial_data = sasl_new({"PLAIN"}, stream.username, stream.password, stream.jid);
		
		stream:debug("Selecting PLAIN mechanism...");
		local auth_stanza = st.stanza("auth", { xmlns = xmlns_sasl, mechanism = "PLAIN" });
		if initial_data then
			auth_stanza:text(initial_data);
		end
		stream:send(auth_stanza);
		return true;
	end
	
	local function handle_sasl(sasl_stanza)
		if sasl_stanza.name == "success" then
			stream.authenticated = true;
			stream:event("authentication-success");
		elseif sasl_stanza.name == "failure" then
			local err = sasl_stanza.tags[1];
			stream:event("authentication-failure", { condition = err.name });
		end
		stream:reopen();
		return true;
	end
	
	stream:hook("stream-features", handle_features, 300);
	stream:hook("stream/"..xmlns_sasl, handle_sasl);
	
	return true;
end

end)
package.preload['verse.plugins.bind'] = (function (...)
local st = require "util.stanza";
local xmlns_bind = "urn:ietf:params:xml:ns:xmpp-bind";

function verse.plugins.bind(stream)
	local function handle_features(features)
		if stream.bound then return; end
		stream:debug("Binding resource...");
		stream:send_iq(st.iq({ type = "set" }):tag("bind", {xmlns=xmlns_bind}):tag("resource"):text(stream.resource),
			function (reply)
				if reply.attr.type == "result" then
					local result_jid = reply
						:get_child("bind", xmlns_bind)
							:get_child("jid")
								:get_text();
					stream.username, stream.host, stream.resource = jid.split(result_jid);
					stream.jid, stream.bound = result_jid, true;
					stream:event("binding-success", full_jid);
				elseif reply.attr.type == "error" then
					local err = reply:child_with_name("error");
					local type, condition, text = reply:get_error();
					stream:event("binding-failure", { error = condition, text = text, type = type });
				end
			end);
	end
	stream:hook("stream-features", handle_features, 200);
	return true;
end

end)
package.preload['verse.plugins.version'] = (function (...)
local xmlns_version = "jabber:iq:version";

local function set_version(self, version_info)
	self.name = version_info.name;
	self.version = version_info.version;
	self.platform = version_info.platform;
end

function verse.plugins.version(stream)
	stream.version = { set = set_version };
	stream:hook("iq/"..xmlns_version, function (stanza)
		if stanza.attr.type ~= "get" then return; end
		local reply = verse.reply(stanza)
			:tag("query", { xmlns = xmlns_version });
		if stream.version.name then
			reply:tag("name"):text(tostring(stream.version.name)):up();
		end
		if stream.version.version then
			reply:tag("version"):text(tostring(stream.version.version)):up()
		end
		if stream.version.platform then
			reply:tag("os"):text(stream.version.platform);
		end
		stream:send(reply);
	end);
	
	function stream:query_version(target_jid, callback)
		callback = callback or function (version) return stream:event("version/response", version); end
		stream:send_iq(verse.iq({ type = "get", to = target_jid })
			:tag("query", { xmlns = xmlns_version }), 
			function (reply)
				local query = reply:get_child("query", xmlns_version);
				if query then
					local name = query:get_child("name");
					local version = query:get_child("version");
					local os = query:get_child("os");
					callback({
						name = name and name:get_text() or nil;
						version = version and version:get_text() or nil;
						platform = os and os:get_text() or nil;
						});
				else
					local type, condition, text = reply:get_error();
					callback({
						error = true;
						condition = condition;
						text = text;
						type = type;
						});
				end
			end);
	end
	return true;
end
end)
package.preload['verse.plugins.ping'] = (function (...)
require "util.xstanza";

local xmlns_ping = "urn:xmpp:ping";

function verse.plugins.ping(stream)
	function stream:ping(jid, callback)
		local t = socket.gettime();
		stream:send_iq(verse.iq{ to = jid, type = "get" }:tag("ping", { xmlns = xmlns_ping }), 
			function (reply)
				if reply.attr.type == "error" then
					local type, condition, text = reply:get_error();
					if condition ~= "service-unavailable" and condition ~= "feature-not-implemented" then
						callback(nil, jid, { type = type, condition = condition, text = text });
						return;
					end
				end
				callback(socket.gettime()-t, jid);
			end);
	end
	return true;
end
end)
package.preload['verse.plugins.session'] = (function (...)
local st = require "util.stanza";
local xmlns_session = "urn:ietf:params:xml:ns:xmpp-session";

function verse.plugins.session(stream)
        local function handle_binding(jid)
                stream:debug("Establishing Session...");
                stream:send_iq(st.iq({ type = "set" }):tag("session", {xmlns=xmlns_session}),
                        function (reply)
                                if reply.attr.type == "result" then
                                        stream:event("session-success");
                                elseif reply.attr.type == "error" then
                                        local err = reply:child_with_name("error");
                                        local type, condition, text = reply:get_error();
                                        stream:event("session-failure", { error = condition, text = text, type = type });
                                end
                        end);
        end
        stream:hook("binding-success", handle_binding);
        return true;
end
end)
package.preload['verse.client'] = (function (...)
local verse = require "verse";
local stream = verse.stream_mt;

local jid_split = require "util.jid".split;
local lxp = require "lxp";
local st = require "util.stanza";

-- Shortcuts to save having to load util.stanza
verse.message, verse.presence, verse.iq, verse.stanza, verse.reply = 
	st.message, st.presence, st.iq, st.stanza, st.reply;

local init_xmlhandlers = require "core.xmlhandlers";

local xmlns_stream = "http://etherx.jabber.org/streams";

local stream_callbacks = {
	stream_ns = xmlns_stream,
	stream_tag = "stream",
	 default_ns = "jabber:client" };
	
function stream_callbacks.streamopened(stream, attr)
	if not stream:event("opened") then
		stream.notopen = nil;
	end
	return true;
end

function stream_callbacks.streamclosed(stream)
	return stream:event("closed");
end

function stream_callbacks.handlestanza(stream, stanza)
	if stanza.attr.xmlns == xmlns_stream then
		return stream:event("stream-"..stanza.name, stanza);
	elseif stanza.attr.xmlns then
		return stream:event("stream/"..stanza.attr.xmlns, stanza);
	end

	return stream:event("stanza", stanza);
end

local function reset_stream(stream)
	-- Reset stream
	local parser = lxp.new(init_xmlhandlers(stream, stream_callbacks), "\1");
	stream.parser = parser;
	
	stream.notopen = true;
	
	function stream.data(conn, data)
		local ok, err = parser:parse(data);
		if ok then return; end
		stream:debug("debug", "Received invalid XML (%s) %d bytes: %s", tostring(err), #data, data:sub(1, 300):gsub("[\r\n]+", " "));
		stream:close("xml-not-well-formed");
	end
	
	return true;
end

function stream:connect_client(jid, pass)
	self.jid, self.password = jid, pass;
	self.username, self.host, self.resource = jid_split(jid);
	
	self:add_plugin("sasl");
	self:add_plugin("bind");
	self:add_plugin("session");
	
	self:hook("incoming-raw", function (data) return self.data(self.conn, data); end);
	
	self.curr_id = 0;
	
	self.tracked_iqs = {};
	self:hook("stanza", function (stanza)
		local id, type = stanza.attr.id, stanza.attr.type;
		if id and stanza.name == "iq" and (type == "result" or type == "error") and self.tracked_iqs[id] then
			self.tracked_iqs[id](stanza);
			self.tracked_iqs[id] = nil;
			return true;
		end
	end);
	
	self:hook("stanza", function (stanza)
		if stanza.attr.xmlns == nil or stanza.attr.xmlns == "jabber:client" then
			if stanza.name == "iq" and (stanza.attr.type == "get" or stanza.attr.type == "set") then
				local xmlns = stanza.tags[1] and stanza.tags[1].attr.xmlns;
				if xmlns then
					ret = self:event("iq/"..xmlns, stanza);
					if not ret then
						ret = self:event("iq", stanza);
					end
				end
			else
				ret = self:event(stanza.name, stanza);
			end
		end
		return ret;
	end, -1);

	-- Initialise connection
	self:connect(self.connect_host or self.host, self.connect_port or 5222);
	--reset_stream(self);	
	self:reopen();
end

function stream:reopen()
	reset_stream(self);
	self:send(st.stanza("stream:stream", { to = self.host, ["xmlns:stream"]='http://etherx.jabber.org/streams',
		xmlns = "jabber:client", version = "1.0" }):top_tag());
end

function stream:close(reason)
	if not self.notopen then
		self:send("</stream:stream>");
	end
	local on_disconnect = self.conn.disconnect();
	self.conn:close();
	on_disconnect(conn, reason);
end

function stream:send_iq(iq, callback)
	local id = self:new_id();
	self.tracked_iqs[id] = callback;
	iq.attr.id = id;
	self:send(iq);
end

function stream:new_id()
	self.curr_id = self.curr_id + 1;
	return tostring(self.curr_id);
end
end)

-- Use LuaRocks if available
pcall(require, "luarocks.require");

local server = require "net.server";
local events = require "util.events";

module("verse", package.seeall);
local verse = _M;

local stream = {};
stream.__index = stream;
stream_mt = stream;

verse.plugins = {};

function verse.new(logger, base)
	local t = setmetatable(base or {}, stream);
	t.id = tostring(t):match("%x*$");
	t:set_logger(logger, true);
	t.events = events.new();
	return t;
end

verse.add_task = require "util.timer".add_task;

function verse.loop()
	return server.loop();
end

function verse.quit()
	return server.setquitting(true);
end

verse.logger = logger.init;

function verse.set_logger(logger)
	server.setlogger(logger);
end

function stream:connect(connect_host, connect_port)
	connect_host = connect_host or "localhost";
	connect_port = tonumber(connect_port) or 5222;
	
	-- Create and initiate connection
	local conn = socket.tcp()
	conn:settimeout(0);
	local success, err = conn:connect(connect_host, connect_port);
	
	if not success and err ~= "timeout" then
		self:warn("connect() to %s:%d failed: %s", connect_host, connect_port, err);
		return false, err;
	end

	--local conn, err = server.addclient(self.connect_host or self.host, tonumber(self.connect_port) or 5222, new_listener(self), "*a");
	local conn = server.wrapclient(conn, connect_host, connect_port, new_listener(self), "*a"); --, hosts[from_host].ssl_ctx, false );
	if not conn then
		return nil, err;
	end
	
	self.conn = conn;
	local w, t = conn.write, tostring;
	self.send = function (_, data) return w(conn, t(data)); end
end

-- Logging functions
function stream:debug(...)
	if self.logger and self.log.debug then
		return self.logger("debug", ...);
	end
end

function stream:warn(...)
	if self.logger and self.log.warn then
		return self.logger("warn", ...);
	end
end

function stream:error(...)
	if self.logger and self.log.error then
		return self.logger("error", ...);
	end
end

function stream:set_logger(logger, levels)
	local old_logger = self.logger;
	if logger then
		self.logger = logger;
	end
	if levels then
		if levels == true then
			levels = { "debug", "info", "warn", "error" };
		end
		self.log = {};
		for _, level in ipairs(levels) do
			self.log[level] = true;
		end
	end
	return old_logger;
end

-- Event handling
function stream:event(name, ...)
	self:debug("Firing event: "..tostring(name));
	return self.events.fire_event(name, ...);
end

function stream:hook(name, ...)
	return self.events.add_handler(name, ...);
end

function stream:add_plugin(name)
	if require("verse.plugins."..name) then
		local ok, err = verse.plugins[name](self);
		if ok then
			self:debug("Loaded %s plugin", name);
		else
			self:warn("Failed to load %s plugin: %s", name, err);
		end
	end
	return self;
end

-- Listener factory
function new_listener(stream)
	local conn_listener = {};
	
	function conn_listener.onincoming(conn, data)
		stream:debug("Data");
		if not stream.connected then
			stream.connected = true;
			stream.send = function (stream, data) stream:debug("Sending data: "..tostring(data)); return conn:write(tostring(data)); end;
			stream:event("connected");
		end
		if data then
			stream:event("incoming-raw", data);
		end
	end
	
	function conn_listener.ondisconnect(conn, err)
		stream.connected = false;
		stream:event("disconnected", { reason = err });
	end
	
	return conn_listener;
end


local log = require "util.logger".init("verse");

return verse;
