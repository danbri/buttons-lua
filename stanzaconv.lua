#!/usr/bin/env lua

-- eval is:  ...
-- f = loadstring(text); f();

-- Title:  Convert XML to Lua stanza generation code
-- Desc:   Takes XML as input and prints out the Lua code 
--         necessary to generate that XML.
-- Author: Matthew Wild <mwild1@gmail.com>
-- Date:   2009-04-05
-- URL:    http://prosody.im/files/stanzaconv.lua

local data = io.read("*a");
local indent_char, indent_step = " ", 4;

local indent, first, short_close = 0, true, nil;
for tagline, text in data:gmatch("<([^>]+)>([^<]*)") do
	if tagline:sub(-1,-1) == "/" then
		tagline = tagline:sub(1, -2);
		short_close = true;
	end
	if tagline:sub(1,1) == "/" then
		io.write(":up()");
		indent = indent - indent_step;
	else
		local name, attr = tagline:match("^(%S*)%s*(.*)$");
		local attr_str = {};
		for k, _, v in attr:gmatch("(%S+)=([\"'])([^%2]-)%2") do
			if #attr_str == 0 then
				table.insert(attr_str, ", { ");
			else
				table.insert(attr_str, ", ");
			end
			if k:match("^%a%w*$") then
				table.insert(attr_str, string.format("%s = %q", k, v));
			else
				table.insert(attr_str, string.format("[%q] = %q", k, v));
			end
		end
		if #attr_str > 0 then
			table.insert(attr_str, " }");
		end
		if first and name == "iq" or name == "presence" or name == "message" then
			io.write(string.format("stanza.%s(%s)", name, table.concat(attr_str):gsub("^, ", "")));
			first = nil;
		else
			io.write(string.format("\n%s:tag(%q%s)", indent_char:rep(indent), name, table.concat(attr_str)));
		end
		if not short_close then
			indent = indent + indent_step;
		end
	end
	if text and text:match("%S") then
		io.write(string.format(":text(%q)", text));
	elseif short_close then
		short_close = nil;
		io.write(":up()");
	end
end

io.write("\n");
