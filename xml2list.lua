#!/usr/bin/lua

local web = require("socket.http");
print("Testing... reading XML");
u = "http://localhost:8080/requests/playlist.xml";
local myxml=web.request( u );
print(myxml);
for w in string.gfind(myxml, "name=\"([^\"]+)\" ro=\"") do
  print("ITEM: " , w);
end

