package.preload['util.encodings']=(function(...)
local function e()
error("Function not implemented");
end
local t=require"mime";
module"encodings"
stringprep={};
base64={encode=t.b64,decode=e};
return _M;
end)
package.preload['util.hashes']=(function(...)
local e=require"util.sha1";
return{sha1=e.sha1};
end)
package.preload['util.logger']=(function(...)
local o,t=select,tostring;
local a=io.write;
module"logger"
local function e(a,...)
local e,o=0,#arg;
return(a:gsub("%%(.)",function(a)if a~="%"and e<=o then e=e+1;return t(arg[e]);end end));
end
local function n(i,...)
local e,o=0,o('#',...);
local a={...};
return(i:gsub("%%(.)",function(i)if e<=o then e=e+1;return t(a[e]);end end));
end
function init(e)
return function(e,t,...)
a(e,"\t",n(t,...),"\n");
end
end
return _M;
end)
package.preload['util.sha1']=(function(...)
local s=string.len
local o=string.char
local j=string.byte
local q=string.sub
local d=math.floor
local t=require"bit"
local k=t.bnot
local e=t.band
local p=t.bor
local n=t.bxor
local i=t.lshift
local a=t.rshift
local l,u,r,h,c
local function y(t,e)
return i(t,e)+a(t,32-e)
end
local function m(i)
local t,a
local t=""
for n=1,8 do
a=e(i,15)
if(a<10)then
t=o(a+48)..t
else
t=o(a+87)..t
end
i=d(i/16)
end
return t
end
local function g(t)
local i,a
local n=""
i=s(t)*8
t=t..o(128)
a=56-e(s(t),63)
if(a<0)then
a=a+64
end
for e=1,a do
t=t..o(0)
end
for t=1,8 do
n=o(e(i,255))..n
i=d(i/256)
end
return t..n
end
local function b(f)
local m,t,i,a,w,d,s,v
local o,o
local o={}
while(f~="")do
for e=0,15 do
o[e]=0
for t=1,4 do
o[e]=o[e]*256+j(f,e*4+t)
end
end
for e=16,79 do
o[e]=y(n(n(o[e-3],o[e-8]),n(o[e-14],o[e-16])),1)
end
m=l
t=u
i=r
a=h
w=c
for h=0,79 do
if(h<20)then
d=p(e(t,i),e(k(t),a))
s=1518500249
elseif(h<40)then
d=n(n(t,i),a)
s=1859775393
elseif(h<60)then
d=p(p(e(t,i),e(t,a)),e(i,a))
s=2400959708
else
d=n(n(t,i),a)
s=3395469782
end
v=y(m,5)+d+w+s+o[h]
w=a
a=i
i=y(t,30)
t=m
m=v
end
l=e(l+m,4294967295)
u=e(u+t,4294967295)
r=e(r+i,4294967295)
h=e(h+a,4294967295)
c=e(c+w,4294967295)
f=q(f,65)
end
end
local function t(e,t)
e=g(e)
l=1732584193
u=4023233417
r=2562383102
h=271733878
c=3285377520
b(e)
local e=m(l)..m(u)..m(r)
..m(h)..m(c);
if t then
return e;
else
return(e:gsub("..",function(e)
return string.char(tonumber(e,16));
end));
end
end
_G.sha1={sha1=t};
return _G.sha1;
end)
package.preload['lib.adhoc']=(function(...)
local n,h=require"util.stanza",require"util.uuid";
local e="http://jabber.org/protocol/commands";
local i={}
local s={};
function _cmdtag(o,i,a,t)
local e=n.stanza("command",{xmlns=e,node=o.node,status=i});
if a then e.attr.sessionid=a;end
if t then e.attr.action=t;end
return e;
end
function s.new(e,t,a,o)
return{name=e,node=t,handler=a,cmdtag=_cmdtag,permission=(o or"user")};
end
function s.handle_cmd(o,s,a)
local e=a.tags[1].attr.sessionid or h.generate();
local t={};
t.to=a.attr.to;
t.from=a.attr.from;
t.action=a.tags[1].attr.action or"execute";
t.form=a.tags[1]:child_with_ns("jabber:x:data");
local t,h=o:handler(t,i[e]);
i[e]=h;
local a=n.reply(a);
if t.status=="completed"then
i[e]=nil;
cmdtag=o:cmdtag("completed",e);
elseif t.status=="canceled"then
i[e]=nil;
cmdtag=o:cmdtag("canceled",e);
elseif t.status=="error"then
i[e]=nil;
a=n.error_reply(a,t.error.type,t.error.condition,t.error.message);
s.send(a);
return true;
else
cmdtag=o:cmdtag("executing",e);
end
for t,e in pairs(t)do
if t=="info"then
cmdtag:tag("note",{type="info"}):text(e):up();
elseif t=="warn"then
cmdtag:tag("note",{type="warn"}):text(e):up();
elseif t=="error"then
cmdtag:tag("note",{type="error"}):text(e.message):up();
elseif t=="actions"then
local t=n.stanza("actions");
for a,e in ipairs(e)do
if(e=="prev")or(e=="next")or(e=="complete")then
t:tag(e):up();
else
module:log("error",'Command "'..o.name..
'" at node "'..o.node..'" provided an invalid action "'..e..'"');
end
end
cmdtag:add_child(t);
elseif t=="form"then
cmdtag:add_child((e.layout or e):form(e.data));
elseif t=="result"then
cmdtag:add_child((e.layout or e):form(e.data,"result"));
elseif t=="other"then
cmdtag:add_child(e);
end
end
a:add_child(cmdtag);
s.send(a);
return true;
end
return s;
end)
package.preload['util.stanza']=(function(...)
local e=table.insert;
local t=table.concat;
local m=table.remove;
local f=table.concat;
local h=string.format;
local w=string.match;
local u=tostring;
local c=setmetatable;
local b=getmetatable;
local s=pairs;
local n=ipairs;
local o=type;
local t=next;
local t=print;
local t=unpack;
local p=string.gsub;
local t=string.char;
local d=string.find;
local t=os;
local l=not t.getenv("WINDIR");
local r,a;
if l then
local t,e=pcall(require,"util.termcolours");
if t then
r,a=e.getstyle,e.getstring;
else
l=nil;
end
end
local y="urn:ietf:params:xml:ns:xmpp-stanzas";
module"stanza"
stanza_mt={__type="stanza"};
stanza_mt.__index=stanza_mt;
function stanza(e,t)
local e={name=e,attr=t or{},tags={},last_add={}};
return c(e,stanza_mt);
end
function stanza_mt:query(e)
return self:tag("query",{xmlns=e});
end
function stanza_mt:body(t,e)
return self:tag("body",e):text(t);
end
function stanza_mt:tag(a,t)
local t=stanza(a,t);
(self.last_add[#self.last_add]or self):add_direct_child(t);
e(self.last_add,t);
return self;
end
function stanza_mt:text(e)
(self.last_add[#self.last_add]or self):add_direct_child(e);
return self;
end
function stanza_mt:up()
m(self.last_add);
return self;
end
function stanza_mt:reset()
local e=self.last_add;
for t=1,#e do
e[t]=nil;
end
return self;
end
function stanza_mt:add_direct_child(t)
if o(t)=="table"then
e(self.tags,t);
end
e(self,t);
end
function stanza_mt:add_child(e)
(self.last_add[#self.last_add]or self):add_direct_child(e);
return self;
end
function stanza_mt:get_child(t,a)
for o,e in n(self.tags)do
if(not t or e.name==t)
and((not a and self.attr.xmlns==e.attr.xmlns)
or e.attr.xmlns==a)then
return e;
end
end
end
function stanza_mt:child_with_name(t)
for a,e in n(self.tags)do
if e.name==t then return e;end
end
end
function stanza_mt:child_with_ns(t)
for a,e in n(self.tags)do
if e.attr.xmlns==t then return e;end
end
end
function stanza_mt:children()
local e=0;
return function(t)
e=e+1
return t[e];
end,self,e;
end
function stanza_mt:matching_tags(a,e)
e=e or self.attr.xmlns;
local t=self.tags;
local o,n=1,#t;
return function()
for i=o,n do
v=t[i];
if(not a or v.name==a)
and(not e or e==v.attr.xmlns)then
o=i+1;
return v;
end
end
end,t,i;
end
function stanza_mt:childtags()
local e=0;
return function(t)
e=e+1
local e=self.tags[e]
if e then return e;end
end,self.tags[1],e;
end
function stanza_mt:maptags(o)
local a,t=self.tags,1;
local n,i=#self,#a;
local e=1;
while t<=i do
if self[e]==a[t]then
local o=o(self[e]);
if o==nil then
m(self,e);
m(a,t);
n=n-1;
i=i-1;
else
self[e]=o;
a[e]=o;
end
e=e+1;
t=t+1;
end
end
return self;
end
local i
do
local e={["'"]="&apos;",["\""]="&quot;",["<"]="&lt;",[">"]="&gt;",["&"]="&amp;"};
function i(t)return(p(t,"['&<>\"]",e));end
_M.xml_escape=i;
end
local function m(o,t,r,a,l)
local i=0;
local h=o.name
e(t,"<"..h);
for o,n in s(o.attr)do
if d(o,"\1",1,true)then
local s,o=w(o,"^([^\1]*)\1?(.*)$");
i=i+1;
e(t," xmlns:ns"..i.."='"..a(s).."' ".."ns"..i..":"..o.."='"..a(n).."'");
elseif not(o=="xmlns"and n==l)then
e(t," "..o.."='"..a(n).."'");
end
end
local i=#o;
if i==0 then
e(t,"/>");
else
e(t,">");
for i=1,i do
local i=o[i];
if i.name then
r(i,t,r,a,o.attr.xmlns);
else
e(t,a(i));
end
end
e(t,"</"..h..">");
end
end
function stanza_mt.__tostring(t)
local e={};
m(t,e,m,i,nil);
return f(e);
end
function stanza_mt.top_tag(t)
local e="";
if t.attr then
for t,a in s(t.attr)do if o(t)=="string"then e=e..h(" %s='%s'",t,i(u(a)));end end
end
return h("<%s%s>",t.name,e);
end
function stanza_mt.get_text(e)
if#e.tags==0 then
return f(e);
end
end
function stanza_mt.get_error(a)
local o,t,e;
local a=a:get_child("error");
if not a then
return nil,nil,nil;
end
o=a.attr.type;
for a in a:children()do
if a.attr.xmlns==y then
if not e and a.name=="text"then
e=a:get_text();
elseif not t then
t=a.name;
end
if t and e then
break;
end
end
end
return o,t or"undefined-condition",e or"";
end
function stanza_mt.__add(e,t)
return e:add_direct_child(t);
end
do
local e=0;
function new_id()
e=e+1;
return"lx"..e;
end
end
function preserialize(t)
local a={name=t.name,attr=t.attr};
for i,t in n(t)do
if o(t)=="table"then
e(a,preserialize(t));
else
e(a,t);
end
end
return a;
end
function deserialize(t)
if t then
local a=t.attr;
for e=1,#a do a[e]=nil;end
local i={};
for e in s(a)do
if d(e,"|",1,true)and not d(e,"\1",1,true)then
local o,t=w(e,"^([^|]+)|(.+)$");
i[o.."\1"..t]=a[e];
a[e]=nil;
end
end
for t,e in s(i)do
a[t]=e;
end
c(t,stanza_mt);
for t,e in n(t)do
if o(e)=="table"then
deserialize(e);
end
end
if not t.tags then
local a={};
for n,i in n(t)do
if o(i)=="table"then
e(a,i);
end
end
t.tags=a;
if not t.last_add then
t.last_add={};
end
end
end
return t;
end
function clone(n)
local i={};
local function a(e)
if o(e)~="table"then
return e;
elseif i[e]then
return i[e];
end
local t={};
i[e]=t;
for e,o in s(e)do
t[a(e)]=a(o);
end
return c(t,b(e));
end
return a(n)
end
function message(e,t)
if not t then
return stanza("message",e);
else
return stanza("message",e):tag("body"):text(t):up();
end
end
function iq(e)
if e and not e.id then e.id=new_id();end
return stanza("iq",e or{id=new_id()});
end
function reply(e)
return stanza(e.name,e.attr and{to=e.attr.from,from=e.attr.to,id=e.attr.id,type=((e.name=="iq"and"result")or e.attr.type)});
end
do
local a={xmlns=y};
function error_reply(e,i,o,t)
local e=reply(e);
e.attr.type="error";
e:tag("error",{type=i})
:tag(o,a):up();
if(t)then e:tag("text",a):text(t):up();end
return e;
end
end
function presence(e)
return stanza("presence",e);
end
if l then
local d=r("yellow");
local l=r("red");
local t=r("red");
local e=r("magenta");
local d=" "..a(d,"%s")..a(e,"=")..a(l,"'%s'");
local r=a(e,"<")..a(t,"%s").."%s"..a(e,">");
local l=r.."%s"..a(e,"</")..a(t,"%s")..a(e,">");
function stanza_mt.pretty_print(t)
local e="";
for a,t in n(t)do
if o(t)=="string"then
e=e..i(t);
else
e=e..t:pretty_print();
end
end
local a="";
if t.attr then
for e,t in s(t.attr)do if o(e)=="string"then a=a..h(d,e,u(t));end end
end
return h(l,t.name,a,e,t.name);
end
function stanza_mt.pretty_top_tag(e)
local t="";
if e.attr then
for e,a in s(e.attr)do if o(e)=="string"then t=t..h(d,e,u(a));end end
end
return h(r,e.name,t);
end
else
stanza_mt.pretty_print=stanza_mt.__tostring;
stanza_mt.pretty_top_tag=stanza_mt.top_tag;
end
return _M;
end)
package.preload['util.timer']=(function(...)
local r=require"net.server".addtimer;
local i=require"net.server".event;
local d=require"net.server".event_base;
local n=os.time;
local s=table.insert;
local e=table.remove;
local e,h=ipairs,pairs;
local l=type;
local o={};
local a={};
module"timer"
local t;
if not i then
function t(e,t)
local o=n();
e=e+o;
if e>=o then
s(a,{e,t});
else
t();
end
end
r(function()
local i=n();
if#a>0 then
for t,e in h(a)do
s(o,e);
end
a={};
end
for n,e in h(o)do
local e,a=e[1],e[2];
if e<=i then
o[n]=nil;
local e=a(i);
if l(e)=="number"then t(e,a);end
end
end
end);
else
local o=(i.core and i.core.LEAVE)or-1;
function t(a,t)
local e;
e=d:addevent(nil,0,function()
local t=t();
if t then
return 0,t;
elseif e then
return o;
end
end
,a);
end
end
add_task=t;
return _M;
end)
package.preload['util.termcolours']=(function(...)
local a,o=table.concat,table.insert;
local e,i=string.char,string.format;
local n=ipairs;
module"termcolours"
local h={
reset=0;bright=1,dim=2,underscore=4,blink=5,reverse=7,hidden=8;
black=30;red=31;green=32;yellow=33;blue=34;magenta=35;cyan=36;white=37;
["black background"]=40;["red background"]=41;["green background"]=42;["yellow background"]=43;["blue background"]=44;["magenta background"]=45;["cyan background"]=46;["white background"]=47;
bold=1,dark=2,underline=4,underlined=4,normal=0;
}
local s=e(27).."[%sm%s"..e(27).."[0m";
function getstring(t,e)
if t then
return i(s,t,e);
else
return e;
end
end
function getstyle(...)
local e,t={...},{};
for a,e in n(e)do
e=h[e];
if e then
o(t,e);
end
end
return a(t,";");
end
return _M;
end)
package.preload['util.uuid']=(function(...)
local e=math.random;
local i=tostring;
local e=os.time;
local n=os.clock;
local a=require"util.hashes".sha1;
module"uuid"
local t=0;
local function o()
local e=e();
if t>=e then e=t+1;end
t=e;
return e;
end
local function e(e)
return a(e..n()..i({}),true);
end
local t=e(o());
local function a(a)
t=e(t..a);
end
local function e(e)
if#t<e then a(o());end
local a=t:sub(0,e);
t=t:sub(e+1);
return a;
end
local function t()
return("%x"):format(e(1):byte()%4+8);
end
function generate()
return e(8).."-"..e(4).."-4"..e(3).."-"..(t())..e(3).."-"..e(12);
end
seed=a;
return _M;
end)
package.preload['net.dns']=(function(...)
local n=require"socket";
local e=require"util.ztact";
local z=require"util.timer";
local t,p=pcall(require,"util.windows");
local T=(t and p)or os.getenv("WINDIR");
local c,E,w,a,r=
coroutine,io,math,string,table;
local y,h,o,u,s,f,k,x,t=
ipairs,next,pairs,print,setmetatable,tostring,assert,error,unpack;
local d,l=e.get,e.set;
local q=15;
module('dns')
local t=_M;
local i=r.insert
local function m(e)
return(e-(e%256))/256;
end
local function v(e)
local t={};
for o,e in o(e)do
t[o]=e;
t[e]=e;
t[a.lower(e)]=e;
end
return t;
end
local function b(i)
local e={};
for t,i in o(i)do
local o=a.char(m(t),t%256);
e[t]=o;
e[i]=o;
e[a.lower(i)]=o;
end
return e;
end
t.types={
'A','NS','MD','MF','CNAME','SOA','MB','MG','MR','NULL','WKS',
'PTR','HINFO','MINFO','MX','TXT',
[28]='AAAA',[29]='LOC',[33]='SRV',
[252]='AXFR',[253]='MAILB',[254]='MAILA',[255]='*'};
t.classes={'IN','CS','CH','HS',[255]='*'};
t.type=v(t.types);
t.class=v(t.classes);
t.typecode=b(t.types);
t.classcode=b(t.classes);
local function g(e,i,o)
if a.byte(e,-1)~=46 then e=e..'.';end
e=a.lower(e);
return e,t.type[i or'A'],t.class[o or'IN'];
end
local function b(a,t,i)
t=t or n.gettime();
for o,e in o(a)do
if e.tod then
e.ttl=w.floor(e.tod-t);
if e.ttl<=0 then
r.remove(a,o);
return b(a,t,i);
end
elseif i=='soft'then
k(e.ttl==0);
a[o]=nil;
end
end
end
local e={};
e.__index=e;
e.timeout=q;
local q;
local k={};
function k.__tostring(t)
local i=a.format('%2s %-5s %6i %-28s',t.class,t.type,t.ttl,t.name);
local o='';
if t.type=='A'then
o=' '..t.a;
elseif t.type=='MX'then
o=a.format(' %2i %s',t.pref,t.mx);
elseif t.type=='CNAME'then
o=' '..t.cname;
elseif t.type=='LOC'then
o=' '..e.LOC_tostring(t);
elseif t.type=='NS'then
o=' '..t.ns;
elseif t.type=='SRV'then
o=' '..q(t);
elseif t.type=='TXT'then
o=' '..t.txt;
else
o=' <UNKNOWN RDATA TYPE>';
end
return i..o;
end
local j={};
function j.__tostring(t)
local e={};
for a,t in o(t)do
i(e,f(t)..'\n');
end
return r.concat(e);
end
local v={};
function v.__tostring(t)
local a=n.gettime();
local e={};
for n,t in o(t)do
for n,t in o(t)do
for o,t in o(t)do
b(t,a);
i(e,f(t));
end
end
end
return r.concat(e);
end
function e:new()
local t={active={},cache={},unsorted={}};
s(t,e);
s(t.cache,v);
s(t.unsorted,{__mode='kv'});
return t;
end
function t.random(...)
w.randomseed(w.floor(1e4*n.gettime()));
t.random=w.random;
return t.random(...);
end
local function _(e)
e=e or{};
e.id=e.id or t.random(0,65535);
e.rd=e.rd or 1;
e.tc=e.tc or 0;
e.aa=e.aa or 0;
e.opcode=e.opcode or 0;
e.qr=e.qr or 0;
e.rcode=e.rcode or 0;
e.z=e.z or 0;
e.ra=e.ra or 0;
e.qdcount=e.qdcount or 1;
e.ancount=e.ancount or 0;
e.nscount=e.nscount or 0;
e.arcount=e.arcount or 0;
local t=a.char(
m(e.id),e.id%256,
e.rd+2*e.tc+4*e.aa+8*e.opcode+128*e.qr,
e.rcode+16*e.z+128*e.ra,
m(e.qdcount),e.qdcount%256,
m(e.ancount),e.ancount%256,
m(e.nscount),e.nscount%256,
m(e.arcount),e.arcount%256
);
return t,e.id;
end
local function m(t)
local e={};
for t in a.gmatch(t,'[^.]+')do
i(e,a.char(a.len(t)));
i(e,t);
end
i(e,a.char(0));
return r.concat(e);
end
local function w(a,o,e)
a=m(a);
o=t.typecode[o or'a'];
e=t.classcode[e or'in'];
return a..o..e;
end
function e:byte(e)
e=e or 1;
local t=self.offset;
local o=t+e-1;
if o>#self.packet then
x(a.format('out of bounds: %i>%i',o,#self.packet));
end
self.offset=t+e;
return a.byte(self.packet,t,o);
end
function e:word()
local e,t=self:byte(2);
return 256*e+t;
end
function e:dword()
local e,t,a,o=self:byte(4);
return 16777216*e+65536*t+256*a+o;
end
function e:sub(e)
e=e or 1;
local t=a.sub(self.packet,self.offset,self.offset+e-1);
self.offset=self.offset+e;
return t;
end
function e:header(t)
local e=self:word();
if not self.active[e]and not t then return nil;end
local e={id=e};
local t,a=self:byte(2);
e.rd=t%2;
e.tc=t/2%2;
e.aa=t/4%2;
e.opcode=t/8%16;
e.qr=t/128;
e.rcode=a%16;
e.z=a/16%8;
e.ra=a/128;
e.qdcount=self:word();
e.ancount=self:word();
e.nscount=self:word();
e.arcount=self:word();
for a,t in o(e)do e[a]=t-t%1;end
return e;
end
function e:name()
local a,t=nil,0;
local e=self:byte();
local o={};
while e>0 do
if e>=192 then
t=t+1;
if t>=20 then x('dns error: 20 pointers');end;
local e=((e-192)*256)+self:byte();
a=a or self.offset;
self.offset=e+1;
else
i(o,self:sub(e)..'.');
end
e=self:byte();
end
self.offset=a or self.offset;
return r.concat(o);
end
function e:question()
local e={};
e.name=self:name();
e.type=t.type[self:word()];
e.class=t.class[self:word()];
return e;
end
function e:A(n)
local t,e,o,i=self:byte(4);
n.a=a.format('%i.%i.%i.%i',t,e,o,i);
end
function e:CNAME(e)
e.cname=self:name();
end
function e:MX(e)
e.pref=self:word();
e.mx=self:name();
end
function e:LOC_nibble_power()
local e=self:byte();
return((e-(e%16))/16)*(10^(e%16));
end
function e:LOC(e)
e.version=self:byte();
if e.version==0 then
e.loc=e.loc or{};
e.loc.size=self:LOC_nibble_power();
e.loc.horiz_pre=self:LOC_nibble_power();
e.loc.vert_pre=self:LOC_nibble_power();
e.loc.latitude=self:dword();
e.loc.longitude=self:dword();
e.loc.altitude=self:dword();
end
end
local function m(e,i,t)
e=e-2147483648;
if e<0 then i=t;e=-e;end
local n,o,t;
t=e%6e4;
e=(e-t)/6e4;
o=e%60;
n=(e-o)/60;
return a.format('%3d %2d %2.3f %s',n,o,t/1e3,i);
end
function e.LOC_tostring(e)
local t={};
i(t,a.format(
'%s    %s    %.2fm %.2fm %.2fm %.2fm',
m(e.loc.latitude,'N','S'),
m(e.loc.longitude,'E','W'),
(e.loc.altitude-1e7)/100,
e.loc.size/100,
e.loc.horiz_pre/100,
e.loc.vert_pre/100
));
return r.concat(t);
end
function e:NS(e)
e.ns=self:name();
end
function e:SOA(e)
end
function e:SRV(e)
e.srv={};
e.srv.priority=self:word();
e.srv.weight=self:word();
e.srv.port=self:word();
e.srv.target=self:name();
end
function e:PTR(e)
e.ptr=self:name();
end
function q(e)
local e=e.srv;
return a.format('%5d %5d %5d %s',e.priority,e.weight,e.port,e.target);
end
function e:TXT(e)
e.txt=self:sub(e.rdlength);
end
function e:rr()
local e={};
s(e,k);
e.name=self:name(self);
e.type=t.type[self:word()]or e.type;
e.class=t.class[self:word()]or e.class;
e.ttl=65536*self:word()+self:word();
e.rdlength=self:word();
if e.ttl<=0 then
e.tod=self.time+30;
else
e.tod=self.time+e.ttl;
end
local a=self.offset;
local t=self[t.type[e.type]];
if t then t(self,e);end
self.offset=a;
e.rdata=self:sub(e.rdlength);
return e;
end
function e:rrs(t)
local e={};
for t=1,t do i(e,self:rr());end
return e;
end
function e:decode(t,o)
self.packet,self.offset=t,1;
local t=self:header(o);
if not t then return nil;end
local t={header=t};
t.question={};
local n=self.offset;
for e=1,t.header.qdcount do
i(t.question,self:question());
end
t.question.raw=a.sub(self.packet,n,self.offset-1);
if not o then
if not self.active[t.header.id]or not self.active[t.header.id][t.question.raw]then
return nil;
end
end
t.answer=self:rrs(t.header.ancount);
t.authority=self:rrs(t.header.nscount);
t.additional=self:rrs(t.header.arcount);
return t;
end
e.delays={1,3};
function e:addnameserver(e)
self.server=self.server or{};
i(self.server,e);
end
function e:setnameserver(e)
self.server={};
self:addnameserver(e);
end
function e:adddefaultnameservers()
if T then
if p and p.get_nameservers then
for t,e in y(p.get_nameservers())do
self:addnameserver(e);
end
end
if not self.server or#self.server==0 then
self:addnameserver("208.67.222.222");
self:addnameserver("208.67.220.220");
end
else
local e=E.open("/etc/resolv.conf");
if e then
for e in e:lines()do
e=e:gsub("#.*$","")
:match('^%s*nameserver%s+(.*)%s*$');
if e then
e:gsub("%f[%d.](%d+%.%d+%.%d+%.%d+)%f[^%d.]",function(e)
self:addnameserver(e)
end);
end
end
end
if not self.server or#self.server==0 then
self:addnameserver("127.0.0.1");
end
end
end
function e:getsocket(t)
self.socket=self.socket or{};
self.socketset=self.socketset or{};
local e=self.socket[t];
if e then return e;end
e=n.udp();
if self.socket_wrapper then e=self.socket_wrapper(e,self);end
e:settimeout(0);
e:setsockname('*',0);
e:setpeername(self.server[t],53);
self.socket[t]=e;
self.socketset[e]=t;
return e;
end
function e:voidsocket(e)
if self.socket[e]then
self.socketset[self.socket[e]]=nil;
self.socket[e]=nil;
elseif self.socketset[e]then
self.socket[self.socketset[e]]=nil;
self.socketset[e]=nil;
end
end
function e:socket_wrapper_set(e)
self.socket_wrapper=e;
end
function e:closeall()
for t,e in y(self.socket)do
self.socket[t]=nil;
self.socketset[e]=nil;
e:close();
end
end
function e:remember(e,t)
local a,n,o=g(e.name,e.type,e.class);
if t~='*'then
t=n;
local t=d(self.cache,o,'*',a);
if t then i(t,e);end
end
self.cache=self.cache or s({},v);
local a=d(self.cache,o,t,a)or
l(self.cache,o,t,a,s({},j));
i(a,e);
if t=='MX'then self.unsorted[a]=true;end
end
local function i(e,t)
return(e.pref==t.pref)and(e.mx<t.mx)or(e.pref<t.pref);
end
function e:peek(a,t,o)
a,t,o=g(a,t,o);
local e=d(self.cache,o,t,a);
if not e then return nil;end
if b(e,n.gettime())and t=='*'or not h(e)then
l(self.cache,o,t,a,nil);
return nil;
end
if self.unsorted[e]then r.sort(e,i);end
return e;
end
function e:purge(e)
if e=='soft'then
self.time=n.gettime();
for t,e in o(self.cache or{})do
for t,e in o(e)do
for t,e in o(e)do
b(e,self.time,'soft')
end
end
end
else self.cache={};end
end
function e:query(e,a,t)
e,a,t=g(e,a,t)
if not self.server then self:adddefaultnameservers();end
local s=w(e,a,t);
local o=self:peek(e,a,t);
if o then return o;end
local o,i=_();
local o={
packet=o..s,
server=self.best_server,
delay=1,
retry=n.gettime()+self.delays[1]
};
self.active[i]=self.active[i]or{};
self.active[i][s]=o;
local i=c.running();
if i then
l(self.wanted,t,a,e,i,true);
end
local n=self:getsocket(o.server)
n:send(o.packet)
if z and self.timeout then
local h=#self.server;
local s=1;
z.add_task(self.timeout,function()
if d(self.wanted,t,a,e,i)then
if s<h then
s=s+1;
self:servfail(n);
o.server=self.best_server;
n=self:getsocket(o.server);
n:send(o.packet);
return self.timeout;
else
self:cancel(t,a,e,i,true);
end
end
end)
end
end
function e:servfail(e)
local t=self.socketset[e]
self:voidsocket(e);
self.time=n.gettime();
for e,a in o(self.active)do
for o,e in o(a)do
if e.server==t then
e.server=e.server+1
if e.server>#self.server then
e.server=1;
end
e.retries=(e.retries or 0)+1;
if e.retries>=#self.server then
a[o]=nil;
else
local t=self:getsocket(e.server);
if t then t:send(e.packet);end
end
end
end
end
if t==self.best_server then
self.best_server=self.best_server+1;
if self.best_server>#self.server then
self.best_server=1;
end
end
end
function e:settimeout(e)
self.timeout=e;
end
function e:receive(t)
self.time=n.gettime();
t=t or self.socket;
local e;
for a,t in o(t)do
if self.socketset[t]then
local t=t:receive();
if t then
e=self:decode(t);
if e and self.active[e.header.id]
and self.active[e.header.id][e.question.raw]then
for a,t in o(e.answer)do
if t.name:sub(-#e.question[1].name,-1)==e.question[1].name then
self:remember(t,e.question[1].type)
end
end
local t=self.active[e.header.id];
t[e.question.raw]=nil;
if not h(t)then self.active[e.header.id]=nil;end
if not h(self.active)then self:closeall();end
local e=e.question[1];
local t=d(self.wanted,e.class,e.type,e.name);
if t then
for t in o(t)do
l(self.yielded,t,e.class,e.type,e.name,nil);
if c.status(t)=="suspended"then c.resume(t);end
end
l(self.wanted,e.class,e.type,e.name,nil);
end
end
end
end
end
return e;
end
function e:feed(a,t,e)
self.time=n.gettime();
local e=self:decode(t,e);
if e and self.active[e.header.id]
and self.active[e.header.id][e.question.raw]then
for a,t in o(e.answer)do
self:remember(t,e.question[1].type);
end
local t=self.active[e.header.id];
t[e.question.raw]=nil;
if not h(t)then self.active[e.header.id]=nil;end
if not h(self.active)then self:closeall();end
local e=e.question[1];
if e then
local t=d(self.wanted,e.class,e.type,e.name);
if t then
for t in o(t)do
l(self.yielded,t,e.class,e.type,e.name,nil);
if c.status(t)=="suspended"then c.resume(t);end
end
l(self.wanted,e.class,e.type,e.name,nil);
end
end
end
return e;
end
function e:cancel(t,a,o,e,i)
local t=d(self.wanted,t,a,o);
if t then
if i then
c.resume(e);
end
t[e]=nil;
end
end
function e:pulse()
while self:receive()do end
if not h(self.active)then return nil;end
self.time=n.gettime();
for a,t in o(self.active)do
for o,e in o(t)do
if self.time>=e.retry then
e.server=e.server+1;
if e.server>#self.server then
e.server=1;
e.delay=e.delay+1;
end
if e.delay>#self.delays then
t[o]=nil;
if not h(t)then self.active[a]=nil;end
if not h(self.active)then return nil;end
else
local t=self.socket[e.server];
if t then t:send(e.packet);end
e.retry=self.time+self.delays[e.delay];
end
end
end
end
if h(self.active)then return true;end
return nil;
end
function e:lookup(a,o,t)
self:query(a,o,t)
while self:pulse()do
local e={}
for t,a in y(self.socket)do
e[t]=a
end
n.select(e,nil,4)
end
return self:peek(a,o,t);
end
function e:lookupex(o,a,e,t)
return self:peek(a,e,t)or self:query(a,e,t);
end
local i={
qr={[0]='query','response'},
opcode={[0]='query','inverse query','server status request'},
aa={[0]='non-authoritative','authoritative'},
tc={[0]='complete','truncated'},
rd={[0]='recursion not desired','recursion desired'},
ra={[0]='recursion not available','recursion available'},
z={[0]='(reserved)'},
rcode={[0]='no error','format error','server failure','name error','not implemented'},
type=t.type,
class=t.class
};
local function n(t,e)
return(i[e]and i[e][t[e]])or'';
end
function e.print(t)
for o,e in o{'id','qr','opcode','aa','tc','rd','ra','z',
'rcode','qdcount','ancount','nscount','arcount'}do
u(a.format('%-30s','header.'..e),t.header[e],n(t.header,e));
end
for e,t in y(t.question)do
u(a.format('question[%i].name         ',e),t.name);
u(a.format('question[%i].type         ',e),t.type);
u(a.format('question[%i].class        ',e),t.class);
end
local h={name=1,type=1,class=1,ttl=1,rdlength=1,rdata=1};
local e;
for s,i in o({'answer','authority','additional'})do
for s,t in o(t[i])do
for h,o in o({'name','type','class','ttl','rdlength'})do
e=a.format('%s[%i].%s',i,s,o);
u(a.format('%-30s',e),t[o],n(t,o));
end
for t,o in o(t)do
if not h[t]then
e=a.format('%s[%i].%s',i,s,t);
u(a.format('%-30s  %s',f(e),f(o)));
end
end
end
end
end
function t.resolver()
local t={active={},cache={},unsorted={},wanted={},yielded={},best_server=1};
s(t,e);
s(t.cache,v);
s(t.unsorted,{__mode='kv'});
return t;
end
local e=t.resolver();
t._resolver=e;
function t.lookup(...)
return e:lookup(...);
end
function t.purge(...)
return e:purge(...);
end
function t.peek(...)
return e:peek(...);
end
function t.query(...)
return e:query(...);
end
function t.feed(...)
return e:feed(...);
end
function t.cancel(...)
return e:cancel(...);
end
function t.settimeout(...)
return e:settimeout(...);
end
function t.socket_wrapper_set(...)
return e:socket_wrapper_set(...);
end
return t;
end)
package.preload['net.adns']=(function(...)
local u=require"net.server";
local a=require"net.dns";
local t=require"util.logger".init("adns");
local e,e=table.insert,table.remove;
local o,i,l=coroutine,tostring,pcall;
local function d(a,a,t,e)return(e-t)+1;end
module"adns"
function lookup(h,e,s,n)
return o.wrap(function(r)
if r then
t("debug","Records for %s already cached, using those...",e);
h(r);
return;
end
t("debug","Records for %s not in cache, sending query (%s)...",e,i(o.running()));
a.query(e,s,n);
o.yield({n or"IN",s or"A",e,o.running()});
t("debug","Reply for %s (%s)",e,i(o.running()));
local a,e=l(h,a.peek(e,s,n));
if not a then
t("error","Error in DNS response handler: %s",i(e));
end
end)(a.peek(e,s,n));
end
function cancel(e,o,n)
t("warn","Cancelling DNS lookup for %s",i(e[3]));
a.cancel(e[1],e[2],e[3],e[4],o);
end
function new_async_socket(i,o)
local s="<unknown>";
local n={};
local e={};
function n.onincoming(o,t)
if t then
a.feed(e,t);
end
end
function n.ondisconnect(i,a)
if a then
t("warn","DNS socket for %s disconnected: %s",s,a);
local e=o.server;
if o.socketset[i]==o.best_server and o.best_server==#e then
t("error","Exhausted all %d configured DNS servers, next lookup will try %s again",#e,e[1]);
end
o:servfail(i);
end
end
e=u.wrapclient(i,"dns",53,n);
if not e then
t("warn","handler is nil");
end
e.settimeout=function()end
e.setsockname=function(t,...)return i:setsockname(...);end
e.setpeername=function(a,...)s=(...);local t=i:setpeername(...);a:set_send(d);return t;end
e.connect=function(t,...)return i:connect(...)end
e.send=function(t,e)return i:send(e);end
return e;
end
a.socket_wrapper_set(new_async_socket);
return _M;
end)
package.preload['net.server']=(function(...)
local r=function(e)
return _G[e]
end
local oe=function(e)
for t,a in pairs(e)do
e[t]=nil
end
end
local H,e=require("util.logger").init("socket"),table.concat;
local i=function(...)return H("debug",e{...});end
local ie=function(...)return H("warn",e{...});end
local e=collectgarbage
local se=1
local D=r"type"
local A=r"pairs"
local ne=r"ipairs"
local s=r"tostring"
local e=r"collectgarbage"
local a=r"os"
local e=r"table"
local t=r"string"
local o=r"coroutine"
local P=a.time
local R=a.difftime
local J=e.concat
local e=e.remove
local Q=t.len
local ye=t.sub
local we=o.wrap
local ce=o.yield
local k=r"ssl"
local L=r"socket"or require"socket"
local X=(k and k.wrap)
local ue=L.bind
local me=L.sleep
local fe=L.select
local e=(k and k.newcontext)
local W
local F
local ae
local Y
local K
local te
local Z
local ee
local he
local re
local V
local l
local le
local e
local S
local de
local v
local h
local I
local d
local n
local x
local p
local f
local m
local a
local o
local b
local N
local U
local O
local T
local G
local u
local _
local E
local q
local j
local z
local C
local B
local g
v={}
h={}
d={}
I={}
n={}
p={}
f={}
x={}
a=0
o=0
b=0
N=0
U=0
O=1
T=0
_=51e3*1024
E=25e3*1024
q=12e5
j=6e4
z=6*60*60
C=false
g=1e3
_maxsslhandshake=30
he=function(c,t,p,u,v,f,m)
m=m or g
local r=0
local y,e=c.onconnect or c.onincoming,c.ondisconnect
local w=t.accept
local e={}
e.shutdown=function()end
e.ssl=function()
return f~=nil
end
e.sslctx=function()
return f
end
e.remove=function()
r=r-1
end
e.close=function()
for a,e in A(n)do
if e.serverport==u then
e.disconnect(e,"server closed")
e:close(true)
end
end
t:close()
o=l(d,t,o)
a=l(h,t,a)
n[t]=nil
e=nil
t=nil
i"server.lua: closed server handler and removed sockets from list"
end
e.ip=function()
return p
end
e.serverport=function()
return u
end
e.socket=function()
return t
end
e.readbuffer=function()
if r>m then
i("server.lua: refused new client connection: server full")
return false
end
local t,o=w(t)
if t then
local o,a=t:getpeername()
t:settimeout(0)
local t,n,e=S(e,c,t,o,u,a,v,f)
if e then
return false
end
r=r+1
i("server.lua: accepted new client connection from ",s(o),":",s(a)," to ",s(u))
return y(t)
elseif o then
i("server.lua: error with new client connection: ",s(o))
return false
end
end
return e
end
S=function(V,e,t,D,G,M,A,b)
t:settimeout(0)
local w
local T
local g
local O
local L=e.onincoming
local R=e.onstatus
local v=e.ondisconnect
local I=e.ondrain
local y={}
local c=0
local B
local S
local H
local r=0
local q=false
local z=false
local P,F=0,0
local _=_
local j=E
local e=y
e.dispatch=function()
return L
end
e.disconnect=function()
return v
end
e.setlistener=function(a,t)
L=t.onincoming
v=t.ondisconnect
R=t.onstatus
I=t.ondrain
end
e.getstats=function()
return F,P
end
e.ssl=function()
return O
end
e.sslctx=function()
return b
end
e.send=function(n,a,o,i)
return w(t,a,o,i)
end
e.receive=function(a,o)
return T(t,a,o)
end
e.shutdown=function(a)
return g(t,a)
end
e.setoption=function(i,a,o)
if t.setoption then
return t:setoption(a,o);
end
return false,"setoption not implemented";
end
e.close=function(u,s)
if not e then return true;end
a=l(h,t,a)
p[e]=nil
if c~=0 then
if not(s or S)then
e.sendbuffer()
if c~=0 then
if e then
e.write=nil
end
B=true
return false
end
else
w(t,J(y,"",1,c),1,r)
end
end
if t then
m=g and g(t)
t:close()
o=l(d,t,o)
n[t]=nil
t=nil
else
i"server.lua: socket already closed"
end
if e then
f[e]=nil
x[e]=nil
e=nil
end
if V then
V.remove()
end
i"server.lua: closed client handler and removed socket from list"
return true
end
e.ip=function()
return D
end
e.serverport=function()
return G
end
e.clientport=function()
return M
end
local x=function(i,a)
r=r+Q(a)
if r>_ then
x[e]="send buffer exceeded"
e.write=Y
return false
elseif t and not d[t]then
o=addsocket(d,t,o)
end
c=c+1
y[c]=a
if e then
f[e]=f[e]or u
end
return true
end
e.write=x
e.bufferqueue=function(t)
return y
end
e.socket=function(a)
return t
end
e.set_mode=function(a,t)
A=t or A
return A
end
e.set_send=function(a,t)
w=t or w
return w
end
e.bufferlen=function(o,t,a)
_=a or _
j=t or j
return r,j,_
end
e.lock_read=function(i,o)
if o==true then
local o=a
a=l(h,t,a)
p[e]=nil
if a~=o then
q=true
end
elseif o==false then
if q then
q=false
a=addsocket(h,t,a)
p[e]=u
end
end
return q
end
e.pause=function(t)
return t:lock_read(true);
end
e.resume=function(t)
return t:lock_read(false);
end
e.lock=function(i,a)
e.lock_read(a)
if a==true then
e.write=Y
local a=o
o=l(d,t,o)
f[e]=nil
if o~=a then
z=true
end
elseif a==false then
e.write=x
if z then
z=false
x("")
end
end
return q,z
end
local q=function()
local o,t,a=T(t,A)
if not t or(t=="wantread"or t=="timeout")then
local o=o or a or""
local a=Q(o)
if a>j then
v(e,"receive buffer exceeded")
e:close(true)
return false
end
local a=a*se
F=F+a
U=U+a
p[e]=u
return L(e,o,t)
else
i("server.lua: client ",s(D),":",s(M)," read error: ",s(t))
S=true
v(e,t)
m=e and e:close()
return false
end
end
local f=function()
local b,a,h,n,p;
local p;
if t then
n=J(y,"",1,c)
b,a,h=w(t,n,1,r)
p=(b or h or 0)*se
P=P+p
N=N+p
m=C and oe(y)
else
b,a,p=false,"closed",0;
end
if b then
c=0
r=0
o=l(d,t,o)
f[e]=nil
if I then
I(e)
end
m=H and e:starttls(nil)
m=B and e:close()
return true
elseif h and(a=="timeout"or a=="wantwrite")then
n=ye(n,h+1,r)
y[1]=n
c=1
r=r-h
f[e]=u
return true
else
i("server.lua: client ",s(D),":",s(M)," write error: ",s(a))
S=true
v(e,a)
m=e and e:close()
return false
end
end
local r;
function e.set_sslctx(n,t)
O=true
b=t;
local u
local c
r=we(function(t)
local n
for r=1,_maxsslhandshake do
o=(u and l(d,t,o))or o
a=(c and l(h,t,a))or a
c,u=nil,nil
m,n=t:dohandshake()
if not n then
i("server.lua: ssl handshake done")
e.readbuffer=q
e.sendbuffer=f
m=R and R(e,"ssl-handshake-complete")
a=addsocket(h,t,a)
return true
else
i("server.lua: error during ssl handshake: ",s(n))
if n=="wantwrite"and not u then
o=addsocket(d,t,o)
u=true
elseif n=="wantread"and not c then
a=addsocket(h,t,a)
c=true
else
break;
end
ce()
end
end
v(e,"ssl handshake failed")
m=e and e:close(true)
return false
end
)
end
if k then
if b then
e:set_sslctx(b);
i("server.lua: ","starting ssl handshake")
local a
t,a=X(t,b)
if a then
i("server.lua: ssl error: ",s(a))
return nil,nil,a
end
t:settimeout(0)
e.readbuffer=r
e.sendbuffer=r
r(t)
if not t then
return nil,nil,"ssl handshake failed";
end
else
local m;
e.starttls=function(f,u)
if u then
m=u;
e:set_sslctx(m);
end
if c>0 then
i"server.lua: we need to do tls, but delaying until send buffer empty"
H=true
return
end
i("server.lua: attempting to start tls on "..s(t))
local c,u=t
t,u=X(t,m)
if u then
i("server.lua: error while starting tls on client: ",s(u))
return nil,u
end
t:settimeout(0)
w=t.send
T=t.receive
g=W
n[t]=e
a=addsocket(h,t,a)
a=l(h,c,a)
o=l(d,c,o)
n[c]=nil
e.starttls=nil
H=nil
O=true
e.readbuffer=r
e.sendbuffer=r
r(t)
end
e.readbuffer=q
e.sendbuffer=f
end
else
e.readbuffer=q
e.sendbuffer=f
end
w=t.send
T=t.receive
g=(O and W)or t.shutdown
n[t]=e
a=addsocket(h,t,a)
return e,t
end
W=function()
end
Y=function()
return false
end
addsocket=function(t,a,e)
if not t[a]then
e=e+1
t[e]=a
t[a]=e
end
return e;
end
l=function(e,i,t)
local o=e[i]
if o then
e[i]=nil
local a=e[t]
e[t]=nil
if a~=i then
e[a]=o
e[o]=a
end
return t-1
end
return t
end
V=function(e)
o=l(d,e,o)
a=l(h,e,a)
n[e]=nil
e:close()
end
local function l(a,t,o)
local e;
local i=t.sendbuffer;
function t.sendbuffer()
i();
if e and t.bufferlen()<o then
a:lock_read(false);
e=nil;
end
end
local i=a.readbuffer;
function a.readbuffer()
i();
if not e and t.bufferlen()>=o then
e=true;
a:lock_read(true);
end
end
end
Z=function(o,e,d,l,r)
local t
if D(d)~="table"then
t="invalid listener table"
end
if D(e)~="number"or not(e>=0 and e<=65535)then
t="invalid port"
elseif v[e]then
t="listeners on port '"..e.."' already exist"
elseif r and not k then
t="luasec not found"
end
if t then
ie("server.lua, port ",e,": ",t)
return nil,t
end
o=o or"*"
local t,s=ue(o,e)
if s then
ie("server.lua, port ",e,": ",s)
return nil,s
end
local s,d=he(d,t,o,e,l,r,g)
if not s then
t:close()
return nil,d
end
t:settimeout(0)
a=addsocket(h,t,a)
v[e]=s
n[t]=s
i("server.lua: new "..(r and"ssl "or"").."server listener on '",o,":",e,"'")
return s
end
ee=function(e)
return v[e];
end
le=function(e)
local t=v[e]
if not t then
return nil,"no server found on port '"..s(e).."'"
end
t:close()
v[e]=nil
return true
end
te=function()
for e,t in A(n)do
t:close()
n[e]=nil
end
a=0
o=0
b=0
v={}
h={}
d={}
I={}
n={}
end
re=function()
return O,T,_,E,q,j,z,C,g,_maxsslhandshake
end
de=function(e)
if D(e)~="table"then
return nil,"invalid settings table"
end
O=tonumber(e.timeout)or O
T=tonumber(e.sleeptime)or T
_=tonumber(e.maxsendlen)or _
E=tonumber(e.maxreadlen)or E
q=tonumber(e.checkinterval)or q
j=tonumber(e.sendtimeout)or j
z=tonumber(e.readtimeout)or z
C=e.cleanqueue
g=e._maxclientsperserver or g
_maxsslhandshake=e._maxsslhandshake or _maxsslhandshake
return true
end
K=function(e)
if D(e)~="function"then
return nil,"invalid listener function"
end
b=b+1
I[b]=e
return true
end
ae=function()
return U,N,a,o,b
end
local e;
setquitting=function(t)
e=not not t;
end
F=function(t)
if e then return"quitting";end
if t then e="once";end
repeat
local a,t,o=fe(h,d,O)
for t,e in ne(t)do
local t=n[e]
if t then
t.sendbuffer()
else
V(e)
i"server.lua: found no handler and closed socket (writelist)"
end
end
for e,t in ne(a)do
local e=n[t]
if e then
e.readbuffer()
else
V(t)
i"server.lua: found no handler and closed socket (readlist)"
end
end
for e,t in A(x)do
e.disconnect()(e,t)
e:close(true)
end
oe(x)
u=P()
if R(u-B)>=1 then
for e=1,b do
I[e](u)
end
B=u
end
me(T)
until e;
if t and e=="once"then e=nil;return;end
return"quitting"
end
step=function()
return F(true);
end
local function c()
return"select";
end
local s=function(t,h,i,a,s,e)
local e=S(nil,a,t,h,i,"clientport",s,e)
n[t]=e
o=addsocket(d,t,o)
if a.onconnect then
local t=e.sendbuffer;
e.sendbuffer=function()
e.sendbuffer=t;
a.onconnect(e);
if#e:bufferqueue()>0 then
return t();
end
end
end
return e,t
end
local o=function(o,a,i,n,h)
local e,t=L.tcp()
if t then
return nil,t
end
e:settimeout(0)
m,t=e:connect(o,a)
if t then
local e=s(e,o,a,i)
else
S(nil,i,e,o,a,"clientport",n,h)
end
end
r"setmetatable"(n,{__mode="k"})
r"setmetatable"(p,{__mode="k"})
r"setmetatable"(f,{__mode="k"})
B=P()
G=P()
K(function()
local e=R(u-G)
if e>q then
G=u
for e,t in A(f)do
if R(u-t)>j then
e.disconnect()(e,"send timeout")
e:close(true)
end
end
for e,t in A(p)do
if R(u-t)>z then
e.disconnect()(e,"read timeout")
e:close()
end
end
end
end
)
local function a(e)
local t=H;
if e then
H=e;
end
return t;
end
return{
addclient=o,
wrapclient=s,
loop=F,
link=l,
stats=ae,
closeall=te,
addtimer=K,
addserver=Z,
getserver=ee,
setlogger=a,
getsettings=re,
setquitting=setquitting,
removeserver=le,
get_backend=c,
changesettings=de,
}
end)
package.preload['core.xmlhandlers']=(function(...)
require"util.stanza"
local m=stanza;
local i=tostring;
local f=table.insert;
local c=table.concat;
local n=require"util.logger".init("xmlhandlers");
local r=error;
module"xmlhandlers"
local w={
["http://www.w3.org/XML/1998/namespace"]="xml";
};
local d="http://etherx.jabber.org/streams";
local t="\1";
local h="^([^"..t.."]*)"..t.."?(.*)$";
function init_xmlhandlers(a,e)
local o={};
local s={};
local n=a.log or n;
local l=e.streamopened;
local u=e.streamclosed;
local n=e.error or function(t,e)r("XML stream error: "..i(e));end;
local y=e.handlestanza;
local i=e.stream_ns or d;
local r=i..t..(e.stream_tag or"stream");
local p=i..t..(e.error_tag or"error");
local d=e.default_ns;
local e;
function s:StartElement(s,t)
if e and#o>0 then
e:text(c(o));
o={};
end
local o,i=s:match(h);
if i==""then
o,i="",o;
end
if o~=d then
t.xmlns=o;
end
for e=1,#t do
local a=t[e];
t[e]=nil;
local e,o=a:match(h);
if o~=""then
e=w[e];
if e then
t[e..":"..o]=t[a];
t[a]=nil;
end
end
end
if not e then
if a.notopen then
if s==r then
if l then
l(a,t);
end
else
n(a,"no-stream");
end
return;
end
if o=="jabber:client"and i~="iq"and i~="presence"and i~="message"then
n(a,"invalid-top-level-element");
end
e=m.stanza(i,t);
else
t.xmlns=nil;
if o~=d then
t.xmlns=o;
end
e:tag(i,t);
end
end
function s:CharacterData(t)
if e then
f(o,t);
end
end
function s:EndElement(t)
if e then
if#o>0 then
e:text(c(o));
o={};
end
if#e.last_add==0 then
if t~=p then
y(a,e);
else
n(a,"stream-error",e);
end
e=nil;
else
e:up();
end
else
if t==r then
if u then
u(a);
end
else
local t,e=t:match(h);
if e==""then
t,e="",t;
end
n(a,"parse-error","unexpected-element-close",e);
end
e,o=nil,{};
end
end
return s;
end
return init_xmlhandlers;
end)
package.preload['util.jid']=(function(...)
local a=string.match;
local s=require"util.encodings".stringprep.nodeprep;
local n=require"util.encodings".stringprep.nameprep;
local h=require"util.encodings".stringprep.resourceprep;
module"jid"
local function o(e)
if not e then return;end
local o,t=a(e,"^([^@/]+)@()");
local t,i=a(e,"^([^@/]+)()",t)
if o and not t then return nil,nil,nil;end
local a=a(e,"^/(.+)$",i);
if(not t)or((not a)and#e>=i)then return nil,nil,nil;end
return o,t,a;
end
split=o;
function bare(e)
local t,e=o(e);
if t and e then
return t.."@"..e;
end
return e;
end
local function i(e)
local a,t,e=o(e);
if t then
t=n(t);
if not t then return;end
if a then
a=s(a);
if not a then return;end
end
if e then
e=h(e);
if not e then return;end
end
return a,t,e;
end
end
prepped_split=i;
function prep(e)
local t,e,a=i(e);
if e then
if t then
e=t.."@"..e;
end
if a then
e=e.."/"..a;
end
end
return e;
end
function join(t,e,a)
if t and e and a then
return t.."@"..e.."/"..a;
elseif t and e then
return t.."@"..e;
elseif e and a then
return e.."/"..a;
elseif e then
return e;
end
return nil;
end
function compare(e,t)
local n,s,i=o(e);
local a,e,t=o(t);
if((a~=nil and a==n)or a==nil)and
((e~=nil and e==s)or e==nil)and
((t~=nil and t==i)or t==nil)then
return true
end
return false
end
return _M;
end)
package.preload['util.events']=(function(...)
local i=pairs;
local o=table.insert;
local n=table.sort;
local h=setmetatable;
local s=next;
module"events"
function new()
local a={};
local t={};
local function r(h,a)
local e=t[a];
if not e or s(e)==nil then return;end
local t={};
for e in i(e)do
o(t,e);
end
n(t,function(t,a)return e[t]>e[a];end);
h[a]=t;
return t;
end;
h(a,{__index=r});
local function s(o,i,n)
local e=t[o];
if e then
e[i]=n or 0;
else
e={[i]=n or 0};
t[o]=e;
end
a[o]=nil;
end;
local function n(o,i)
local e=t[o];
if e then
e[i]=nil;
a[o]=nil;
end
end;
local function r(e)
for e,t in i(e)do
s(e,t);
end
end;
local function h(e)
for e,t in i(e)do
n(e,t);
end
end;
local function o(e,...)
local e=a[e];
if e then
for t=1,#e do
local e=e[t](...);
if e~=nil then return e;end
end
end
end;
return{
add_handler=s;
remove_handler=n;
add_handlers=r;
remove_handlers=h;
fire_event=o;
_handlers=a;
_event_map=t;
};
end
return _M;
end)
package.preload['util.dataforms']=(function(...)
local a=setmetatable;
local e,i=pairs,ipairs;
local s,n=tostring,type;
local r=table.concat;
local o=require"util.stanza";
module"dataforms"
local e='jabber:x:data';
local h={};
local t={__index=h};
function new(e)
return a(e,t);
end
function h.form(t,h,a)
local e=o.stanza("x",{xmlns=e,type=a or"form"});
if t.title then
e:tag("title"):text(t.title):up();
end
if t.instructions then
e:tag("instructions"):text(t.instructions):up();
end
for t,o in i(t)do
local a=o.type or"text-single";
e:tag("field",{type=a,var=o.name,label=o.label});
local t=(h and h[o.name])or o.value;
if t then
if a=="hidden"then
if n(t)=="table"then
e:tag("value")
:add_child(t)
:up();
else
e:tag("value"):text(s(t)):up();
end
elseif a=="boolean"then
e:tag("value"):text((t and"1")or"0"):up();
elseif a=="fixed"then
elseif a=="jid-multi"then
for a,t in i(t)do
e:tag("value"):text(t):up();
end
elseif a=="jid-single"then
e:tag("value"):text(t):up();
elseif a=="text-single"or a=="text-private"then
e:tag("value"):text(t):up();
elseif a=="text-multi"then
for t in t:gmatch("([^\r\n]+)\r?\n*")do
e:tag("value"):text(t):up();
end
elseif a=="list-single"then
local a=false;
if n(t)=="string"then
e:tag("value"):text(t):up();
else
for o,t in i(t)do
if n(t)=="table"then
e:tag("option",{label=t.label}):tag("value"):text(t.value):up():up();
if t.default and(not a)then
e:tag("value"):text(t.value):up();
a=true;
end
else
e:tag("option",{label=t}):tag("value"):text(s(t)):up():up();
end
end
end
elseif a=="list-multi"then
for a,t in i(t)do
if n(t)=="table"then
e:tag("option",{label=t.label}):tag("value"):text(t.value):up():up();
if t.default then
e:tag("value"):text(t.value):up();
end
else
e:tag("option",{label=t}):tag("value"):text(s(t)):up():up();
end
end
end
end
if o.required then
e:tag("required"):up();
end
e:up();
end
return e;
end
local e={};
function h.data(n,t)
local a={};
for t in t:childtags()do
local o;
for a,e in i(n)do
if e.name==t.attr.var then
o=e.type;
break;
end
end
local e=e[o];
if e then
a[t.attr.var]=e(t);
end
end
return a;
end
e["text-single"]=
function(t)
local t=t:child_with_name("value");
if t then
return t[1];
end
end
e["text-private"]=
e["text-single"];
e["jid-single"]=
e["text-single"];
e["jid-multi"]=
function(a)
local t={};
for e in a:childtags()do
if e.name=="value"then
t[#t+1]=e[1];
end
end
return t;
end
e["text-multi"]=
function(a)
local t={};
for e in a:childtags()do
if e.name=="value"then
t[#t+1]=e[1];
end
end
return r(t,"\n");
end
e["list-single"]=
e["text-single"];
e["list-multi"]=
function(a)
local t={};
for e in a:childtags()do
if e.name=="value"then
t[#t+1]=e[1];
end
end
return t;
end
e["boolean"]=
function(t)
local t=t:child_with_name("value");
if t then
if t[1]=="1"or t[1]=="true"then
return true;
else
return false;
end
end
end
e["hidden"]=
function(e)
local e=e:child_with_name("value");
if e then
return e[1];
end
end
return _M;
end)
package.preload['util.ztact']=(function(...)
pcall(require,'lfs')
pcall(require,'pozix')
local s,m,r,d,l,f,o,u,n=
getfenv,ipairs,next,pairs,pcall,require,select,tostring,type
local w,y=
unpack,xpcall
local e,t,g,a,i,h=io,lfs,os,string,table,pozix
local b,v=assert,print
local c=error
module((...)or'ztact')
function dir(e)
local e=t.dir(e)
return function()
repeat
local e=e()
if e~='.'and e~='..'then return e end
until not e
end end
function is_file(e)
local t=t.attributes(e,'mode')
return t=='file'and e
end
function htons(e)
return(e-e%256)/256,e%256
end
s().pcall=l
local l,s,t,c
local function p()
local e=s
s=nil
return c(w(e,1,l))
end
function seterrorhandler(e)
t=e
end
function pcall2(e,...)
c=e
l=o('#',...)
s={...}
if not t then
local e=f('debug')
t=e.traceback
end
return y(p,t)
end
function append(t,...)
local a=i.insert
for o,e in m{...}do
a(t,e)
end end
function print_r(o,i)
local a=a.rep('  ',i or 0)
if n(o)=='table'then
for o,t in d(o)do
if n(t)=='table'then
e.write(a,o,'\n')
print_r(t,(i or 0)+1)
else e.write(a,o,' = ',u(t),'\n')end
end
else e.write(o,'\n')end
end
function tohex(e)
return a.format(a.rep('%02x ',#e),a.byte(e,1,#e))
end
function tostring_r(o,r,s)
local e=s or{}
local h=a.rep('  ',r or 0)
if n(o)=='table'then
for a,t in d(o)do
if n(t)=='table'then
append(e,h,a,'\n')
tostring_r(t,(r or 0)+1,e)
else append(e,h,a,' = ',u(t),'\n')end
end
else append(e,o,'\n')end
if not s then return i.concat(e)end
end
local function s(t,...)
for a=1,10 do e.write((t[a]or'.')..' ')end
e.write('\t')
for a=1,6 do e.write((t.p[a]or'.')..' ')end
v(...)
end
function dequeue(t)
local e=t.p
if not e and t[1]then t.p={1,#t}e=t.p end
if not e[1]then return nil end
local a=t[e[1]]
t[e[1]]=nil
if e[1]<e[2]then e[1]=e[1]+1
elseif e[4]then e[1],e[2],e[3],e[4]=e[3],e[4],nil,nil
elseif e[5]then e[1],e[2],e[5],e[6]=e[5],e[6],nil,nil
else e[1],e[2]=nil,nil end
s(t,'  de '..a)
return a
end
function enqueue(t,a)
local e=t.p
if not e then t.p={}e=t.p end
if e[5]then
e[6]=e[6]+1
t[e[6]]=a
elseif e[3]then
if e[4]+1<e[1]then
e[4]=e[4]+1
t[e[4]]=a
else
e[5]=e[2]+1
e[6],t[e[5]]=e[5],a
end
elseif e[1]then
if e[1]==1 then
e[2]=e[2]+1
t[e[2]]=a
else
e[3],e[4],t[1]=1,1,a
end
else
e[1],e[2],t[1]=1,1,a
end
s(t,'     '..a)
end
local function e()
local e={}
enqueue(e,1)
enqueue(e,2)
enqueue(e,3)
enqueue(e,4)
enqueue(e,5)
dequeue(e)
dequeue(e)
enqueue(e,6)
enqueue(e,7)
enqueue(e,8)
enqueue(e,9)
dequeue(e)
dequeue(e)
dequeue(e)
dequeue(e)
enqueue(e,'a')
dequeue(e)
enqueue(e,'b')
enqueue(e,'c')
dequeue(e)
dequeue(e)
dequeue(e)
dequeue(e)
dequeue(e)
enqueue(e,'d')
dequeue(e)
dequeue(e)
dequeue(e)
end
function queue_len(e)
end
function queue_peek(e)
end
function set(a,...)
local e=o('#',...)
local s,i=o(e-1,...)
local t,n
for e=1,e-2 do
local o=o(e,...)
local e=a[o]
if i==nil then
if e==nil then return
elseif r(e,r(e))then t=nil n=nil
elseif t==nil then t=a n=o end
elseif e==nil then e={}a[o]=e end
a=e
end
if i==nil and t then t[n]=nil
else a[s]=i return i end
end
function get(e,...)
local t=o('#',...)
for t=1,t do
e=e[o(t,...)]
if e==nil then break end
end
return e
end
function find(e,...)
local t,a={e},{...}
for t in ivalues(a)do
if not t(e)then break end end
while r(t)do
local o=i.remove(t)
for e in b(h.opendir(o))do
if e and e~='.'and e~='..'then
local e=o..'/'..e
if h.stat(e,'is_dir')then i.insert(t,e)end
for t in ivalues(a)do
if not t(e)then break end end
end end end end
function ivalues(t)
local e=0
return function()if t[e+1]then e=e+1 return t[e]end end
end
function lson_encode(h,e,t,o)
local s
if not e then
s={}
e=function(e)append(s,e)end
end
t=t or 0
o=o or{}
o[t]=o[t]or a.rep(' ',2*t)
local n=n(h)
if n=='number'then e(h)
else if n=='string'then e(a.format('%q',h))
else if n=='table'then
e('{')
for a,i in d(h)do
e('\n')
e(o[t])
e('[')e(lson_encode(a))e('] = ')
lson_encode(i,e,t+1,o)
e(',')
end
e(' }')
end end end
if s then return i.concat(s)end
end
function timestamp(e)
return g.date('%Y%m%d.%H%M%S',e)
end
function values(a)
local t,e
return function()t,e=r(a,t)return e end
end
end)
package.preload['verse.plugins.tls']=(function(...)
local o=require"util.stanza";
local t="urn:ietf:params:xml:ns:xmpp-tls";
function verse.plugins.tls(e)
local function i(a)
if e.authenticated then return;end
if a:get_child("starttls",t)and e.conn.starttls then
e:debug("Negotiating TLS...");
e:send(o.stanza("starttls",{xmlns=t}));
return true;
elseif not e.conn.starttls and not e.secure then
e:warn("SSL libary (LuaSec) not loaded, so TLS not available");
elseif not e.secure then
e:debug("Server doesn't offer TLS :(");
end
end
local function a(t)
if t.name=="proceed"then
e:debug("Server says proceed, handshake starting...");
e.conn:starttls({mode="client",protocol="sslv23",options="no_sslv2"},true);
end
end
local function o(t)
if t=="ssl-handshake-complete"then
e.secure=true;
e:debug("Re-opening stream...");
e:reopen();
end
end
e:hook("stream-features",i,400);
e:hook("stream/"..t,a);
e:hook("status",o,400);
return true;
end
end)
package.preload['verse.plugins.sasl']=(function(...)
local a=require"util.stanza";
local t=require"mime".b64;
local o="urn:ietf:params:xml:ns:xmpp-sasl";
function verse.plugins.sasl(e)
local function i(i)
if e.authenticated then return;end
e:debug("Authenticating with SASL...");
local t=t("\0"..e.username.."\0"..e.password);
e:debug("Selecting PLAIN mechanism...");
local a=a.stanza("auth",{xmlns=o,mechanism="PLAIN"});
if t then
a:text(t);
end
e:send(a);
return true;
end
local function a(t)
if t.name=="success"then
e.authenticated=true;
e:event("authentication-success");
elseif t.name=="failure"then
local t=t.tags[1];
e:event("authentication-failure",{condition=t.name});
end
e:reopen();
return true;
end
e:hook("stream-features",i,300);
e:hook("stream/"..o,a);
return true;
end
end)
package.preload['verse.plugins.bind']=(function(...)
local t=require"util.stanza";
local a="urn:ietf:params:xml:ns:xmpp-bind";
function verse.plugins.bind(e)
local function o(o)
if e.bound then return;end
e:debug("Binding resource...");
e:send_iq(t.iq({type="set"}):tag("bind",{xmlns=a}):tag("resource"):text(e.resource),
function(t)
if t.attr.type=="result"then
local t=t
:get_child("bind",a)
:get_child("jid")
:get_text();
e.username,e.host,e.resource=jid.split(t);
e.jid,e.bound=t,true;
e:event("bind-success",full_jid);
elseif t.attr.type=="error"then
local a=t:child_with_name("error");
local t,o,a=t:get_error();
e:event("bind-failure",{error=o,text=a,type=t});
end
end);
end
e:hook("stream-features",o,200);
return true;
end
end)
package.preload['verse.plugins.version']=(function(...)
local a="jabber:iq:version";
local function o(t,e)
t.name=e.name;
t.version=e.version;
t.platform=e.platform;
end
function verse.plugins.version(e)
e.version={set=o};
e:hook("iq/"..a,function(t)
if t.attr.type~="get"then return;end
local t=verse.reply(t)
:tag("query",{xmlns=a});
if e.version.name then
t:tag("name"):text(tostring(e.version.name)):up();
end
if e.version.version then
t:tag("version"):text(tostring(e.version.version)):up()
end
if e.version.platform then
t:tag("os"):text(e.version.platform);
end
e:send(t);
return true;
end);
function e:query_version(o,t)
t=t or function(t)return e:event("version/response",t);end
e:send_iq(verse.iq({type="get",to=o})
:tag("query",{xmlns=a}),
function(o)
local e=o:get_child("query",a);
if o.attr.type=="result"then
local a=e:get_child("name");
local o=e:get_child("version");
local e=e:get_child("os");
t({
name=a and a:get_text()or nil;
version=o and o:get_text()or nil;
platform=e and e:get_text()or nil;
});
else
local e,a,o=o:get_error();
t({
error=true;
condition=a;
text=o;
type=e;
});
end
end);
end
return true;
end
end)
package.preload['verse.plugins.ping']=(function(...)
local o="urn:xmpp:ping";
function verse.plugins.ping(e)
function e:ping(t,a)
local n=socket.gettime();
e:send_iq(verse.iq{to=t,type="get"}:tag("ping",{xmlns=o}),
function(e)
if e.attr.type=="error"then
local o,e,i=e:get_error();
if e~="service-unavailable"and e~="feature-not-implemented"then
a(nil,t,{type=o,condition=e,text=i});
return;
end
end
a(socket.gettime()-n,t);
end);
end
return true;
end
end)
package.preload['verse.plugins.session']=(function(...)
local o=require"util.stanza";
local a="urn:ietf:params:xml:ns:xmpp-session";
function verse.plugins.session(e)
local function n(t)
local t=t:get_child("session",a);
if t and not t:get_child("optional")then
local function i(t)
e:debug("Establishing Session...");
e:send_iq(o.iq({type="set"}):tag("session",{xmlns=a}),
function(t)
if t.attr.type=="result"then
e:event("session-success");
elseif t.attr.type=="error"then
local a=t:child_with_name("error");
local o,t,a=t:get_error();
e:event("session-failure",{error=t,text=a,type=o});
end
end);
return true;
end
e:hook("bind-success",i);
end
end
e:hook("stream-features",n);
return true;
end
end)
package.preload['verse.plugins.compression']=(function(...)
local t=require"util.stanza";
local i=require"zlib";
local e="http://jabber.org/features/compress"
local a="http://jabber.org/protocol/compress"
local e="http://etherx.jabber.org/streams";
local o=9;
local function s(e)
local i,o=pcall(i.deflate,o);
if i==false then
local t=t.stanza("failure",{xmlns=a}):tag("setup-failed");
e:send(t);
e:error("Failed to create zlib.deflate filter: %s",tostring(o));
return
end
return o
end
local function n(o)
local i,e=pcall(i.inflate);
if i==false then
local t=t.stanza("failure",{xmlns=a}):tag("setup-failed");
o:send(t);
o:error("Failed to create zlib.inflate filter: %s",tostring(e));
return
end
return e
end
local function i(e,a)
function e:send(o)
local o,a,i=pcall(a,tostring(o),'sync');
if o==false then
e:close({
condition="undefined-condition";
text=a;
extra=t.stanza("failure",{xmlns="http://jabber.org/protocol/compress"}):tag("processing-failed");
});
e:warn("Compressed send failed: %s",tostring(a));
return;
end
e.conn:write(a);
end;
end
local function r(e,o)
local n=e.data
e.data=function(i,a)
e:debug("Decompressing data...");
local o,a,s=pcall(o,a);
if o==false then
e:close({
condition="undefined-condition";
text=a;
extra=t.stanza("failure",{xmlns="http://jabber.org/protocol/compress"}):tag("processing-failed");
});
stream:warn("%s",tostring(a));
return;
end
return n(i,a);
end;
end
function verse.plugins.compression(e)
local function h(o)
if not e.compressed then
local o=o:child_with_name("compression");
if o then
for o in o:children()do
local o=o[1]
if o=="zlib"then
e:send(t.stanza("compress",{xmlns=a}):tag("method"):text("zlib"))
e:debug("Enabled compression using zlib.")
return true;
end
end
session:debug("Remote server supports no compression algorithm we support.")
end
end
end
local function o(a)
if a.name=="compressed"then
e:debug("Activating compression...")
local a=s(e);
if not a then return end
local t=n(e);
if not t then return end
i(e,a);
r(e,t);
e.compressed=true;
e:reopen();
elseif a.name=="failure"then
e:warn("Failed to establish compression");
end
end
e:hook("stream-features",h,250);
e:hook("stream/"..a,o);
end
end)
package.preload['verse.plugins.blocking']=(function(...)
local a="urn:xmpp:blocking";
function verse.plugins.blocking(e)
e.blocking={};
function e.blocking:block_jid(o,t)
e:send_iq(verse.iq{type="set"}
:tag("block",{xmlns=a})
:tag("item",{jid=o})
,function()return t and t(true);end
,function()return t and t(false);end
);
end
function e.blocking:unblock_jid(o,t)
e:send_iq(verse.iq{type="set"}
:tag("unblock",{xmlns=a})
:tag("item",{jid=o})
,function()return t and t(true);end
,function()return t and t(false);end
);
end
function e.blocking:unblock_all_jids(t)
e:send_iq(verse.iq{type="set"}
:tag("unblock",{xmlns=a})
,function()return t and t(true);end
,function()return t and t(false);end
);
end
function e.blocking:get_blocked_jids(t)
e:send_iq(verse.iq{type="get"}
:tag("blocklist",{xmlns=a})
,function(e)
local a=e:get_child("blocklist",a);
if not a then return t and t(false);end
local e={};
for t in a:childtags()do
e[#e+1]=t.attr.jid;
end
return t and t(e);
end
,function(e)return t and t(false);end
);
end
end
end)
package.preload['verse.plugins.proxy65']=(function(...)
local e=require"util.events";
local h=require"util.uuid";
local r=require"util.sha1";
local i={};
i.__index=i;
local o="http://jabber.org/protocol/bytestreams";
local n;
function verse.plugins.proxy65(t)
t.proxy65=setmetatable({stream=t},i);
t.proxy65.available_streamhosts={};
local e=0;
t:hook("disco/service-discovered/proxy",function(a)
if a.type=="bytestreams"then
e=e+1;
t:send_iq(verse.iq({to=a.jid,type="get"})
:tag("query",{xmlns=o}),function(a)
e=e-1;
if a.attr.type=="result"then
local e=a:get_child("query",o)
:get_child("streamhost").attr;
t.proxy65.available_streamhosts[e.jid]={
jid=e.jid;
host=e.host;
port=tonumber(e.port);
};
end
if e==0 then
t:event("proxy65/discovered-proxies",t.proxy65.available_streamhosts);
end
end);
end
end);
t:hook("iq/"..o,function(a)
local e=verse.new(nil,{
initiator_jid=a.attr.from,
streamhosts={},
current_host=0;
});
for t in a.tags[1]:childtags()do
if t.name=="streamhost"then
table.insert(e.streamhosts,t.attr);
end
end
local function o()
if e.current_host<#e.streamhosts then
e.current_host=e.current_host+1;
e:connect(
e.streamhosts[e.current_host].host,
e.streamhosts[e.current_host].port
);
n(t,e,a.tags[1].attr.sid,a.attr.from,t.jid);
return true;
end
e:unhook("disconnected",o);
t:send(verse.error_reply(a,"cancel","item-not-found"));
end
function e:accept()
e:hook("disconnected",o,100);
e:hook("connected",function()
e:unhook("disconnected",o);
local e=verse.reply(a)
:tag("query",a.tags[1].attr)
:tag("streamhost-used",{jid=e.streamhosts[e.current_host].jid});
t:send(e);
end,100);
o();
end
function e:refuse()
end
t:event("proxy65/request",e);
end);
end
function i:new(t,s)
local e=verse.new(nil,{
target_jid=t;
bytestream_sid=h.generate();
});
local a=verse.iq{type="set",to=t}
:tag("query",{xmlns=o,mode="tcp",sid=e.bytestream_sid});
for t,e in ipairs(s or self.proxies)do
a:tag("streamhost",e):up();
end
self.stream:send_iq(a,function(a)
if a.attr.type=="error"then
local t,a,o=a:get_error();
e:event("connection-failed",{conn=e,type=t,condition=a,text=o});
else
local a=a.tags[1]:get_child("streamhost-used");
if not a then
end
e.streamhost_jid=a.attr.jid;
local i,a;
for o,t in ipairs(s or self.proxies)do
if t.jid==e.streamhost_jid then
i,a=t.host,t.port;
break;
end
end
if not(i and a)then
end
e:connect(i,a);
local function a()
e:unhook("connected",a);
local t=verse.iq{to=e.streamhost_jid,type="set"}
:tag("query",{xmlns=o,sid=e.bytestream_sid})
:tag("activate"):text(t);
self.stream:send_iq(t,function(t)
if t.attr.type=="result"then
e:event("connected",e);
else
end
end);
return true;
end
e:hook("connected",a,100);
n(self.stream,e,e.bytestream_sid,self.stream.jid,t);
end
end);
return e;
end
function n(i,e,a,o,t)
local a=r.sha1(a..o..t);
local function o()
e:unhook("connected",o);
return true;
end
local function t(a)
e:unhook("incoming-raw",t);
if a:sub(1,2)~="\005\000"then
return e:event("error","connection-failure");
end
e:event("connected");
return true;
end
local function i(o)
e:unhook("incoming-raw",i);
if o~="\005\000"then
local t="version-mismatch";
if o:sub(1,1)=="\005"then
t="authentication-failure";
end
return e:event("error",t);
end
e:send(string.char(5,1,0,3,#a)..a.."\0\0");
e:hook("incoming-raw",t,100);
return true;
end
e:hook("connected",o,200);
e:hook("incoming-raw",i,100);
e:send("\005\001\000");
end
end)
package.preload['verse.plugins.jingle']=(function(...)
local e=require"util.sha1".sha1;
local n=require"util.stanza";
local e=require"util.timer";
local i=require"util.uuid".generate;
local o="urn:xmpp:jingle:1";
local h="urn:xmpp:jingle:errors:1";
local t={};
t.__index=t;
local e={};
local e={};
function verse.plugins.jingle(e)
e:hook("ready",function()
e:add_disco_feature(o);
end,10);
function e:jingle(a)
return verse.eventable(setmetatable(base or{
role="initiator";
peer=a;
sid=i();
stream=e;
},t));
end
function e:register_jingle_transport(e)
end
function e:register_jingle_content_type(e)
end
local function u(i)
local r=i:get_child("jingle",o);
local a=r.attr.sid;
local s=r.attr.action;
local a=e:event("jingle/"..a,i);
if a==true then
e:send(verse.reply(i));
return true;
end
if s~="session-initiate"then
local t=n.error_reply(i,"cancel","item-not-found")
:tag("unknown-session",{xmlns=h}):up();
e:send(t);
return;
end
local l=r.attr.sid;
local a=verse.eventable{
role="receiver";
peer=i.attr.from;
sid=l;
stream=e;
};
setmetatable(a,t);
local d;
local h,s;
for t in r:childtags()do
if t.name=="content"and t.attr.xmlns==o then
local i=t:child_with_name("description");
local o=i.attr.xmlns;
if o then
local e=e:event("jingle/content/"..o,a,i);
if e then
h=e;
end
end
local o=t:child_with_name("transport");
local i=o.attr.xmlns;
s=e:event("jingle/transport/"..i,a,o);
if h and s then
d=t;
break;
end
end
end
if not h then
e:send(n.error_reply(i,"cancel","feature-not-implemented","The specified content is not supported"));
return;
end
if not s then
e:send(n.error_reply(i,"cancel","feature-not-implemented","The specified transport is not supported"));
return;
end
e:send(n.reply(i));
a.content_tag=d;
a.creator,a.name=d.attr.creator,d.attr.name;
a.content,a.transport=h,s;
function a:decline()
end
e:hook("jingle/"..l,function(e)
if e.attr.from~=a.peer then
return false;
end
local e=e:get_child("jingle",o);
return a:handle_command(e);
end);
e:event("jingle",a);
return true;
end
function t:handle_command(a)
local t=a.attr.action;
e:debug("Handling Jingle command: %s",t);
if t=="session-terminate"then
self:destroy();
elseif t=="session-accept"then
self:handle_accepted(a);
elseif t=="transport-info"then
e:debug("Handling transport-info");
self.transport:info_received(a);
elseif t=="transport-replace"then
e:error("Peer wanted to swap transport, not implemented");
else
e:warn("Unhandled Jingle command: %s",t);
return nil;
end
return true;
end
function t:send_command(e,a,t)
local e=n.iq({to=self.peer,type="set"})
:tag("jingle",{
xmlns=o,
sid=self.sid,
action=e,
initiator=self.role=="initiator"and self.stream.jid or nil,
responder=self.role=="responder"and self.jid or nil,
}):add_child(a);
if not t then
self.stream:send(e);
else
self.stream:send_iq(e,t);
end
end
function t:accept(t)
local a=n.iq({to=self.peer,type="set"})
:tag("jingle",{
xmlns=o,
sid=self.sid,
action="session-accept",
responder=e.jid,
})
:tag("content",{creator=self.creator,name=self.name});
local o=self.content:generate_accept(self.content_tag:child_with_name("description"),t);
a:add_child(o);
local t=self.transport:generate_accept(self.content_tag:child_with_name("transport"),t);
a:add_child(t);
local t=self;
e:send_iq(a,function(a)
if a.attr.type=="error"then
local a,t,a=a:get_error();
e:error("session-accept rejected: %s",t);
return false;
end
t.transport:connect(function(a)
e:warn("CONNECTED (receiver)!!!");
t.state="active";
t:event("connected",a);
end);
end);
end
e:hook("iq/"..o,u);
return true;
end
function t:offer(t,a)
local e=n.iq({to=self.peer,type="set"})
:tag("jingle",{xmlns=o,action="session-initiate",
initiator=self.stream.jid,sid=self.sid});
e:tag("content",{creator=self.role,name=t});
local t=self.stream:event("jingle/describe/"..t,a);
if not t then
return false,"Unknown content type";
end
e:add_child(t);
local t=self.stream:event("jingle/transport/".."urn:xmpp:jingle:transports:s5b:1",self);
self.transport=t;
e:add_child(t:generate_initiate());
self.stream:debug("Hooking %s","jingle/"..self.sid);
self.stream:hook("jingle/"..self.sid,function(e)
if e.attr.from~=self.peer then
return false;
end
local e=e:get_child("jingle",o);
return self:handle_command(e)
end);
self.stream:send_iq(e,function(e)
if e.type=="error"then
self.state="terminated";
local a,t,e=e:get_error();
return self:event("error",{type=a,condition=t,text=e});
end
end);
self.state="pending";
end
function t:terminate(e)
local e=verse.stanza("reason"):tag(e or"success");
self:send_command("session-terminate",e,function(e)
self.state="terminated";
self.transport:disconnect();
self:destroy();
end);
end
function t:destroy()
self:event("terminated");
self.stream:unhook("jingle/"..self.sid,self.handle_command);
end
function t:handle_accepted(e)
local e=e:child_with_name("transport");
self.transport:handle_accepted(e);
self.transport:connect(function(e)
print("CONNECTED (initiator)!")
self.state="active";
self:event("connected",e);
end);
end
function t:set_source(a,o)
local function t()
local e,i=a();
if e and e~=""then
self.transport.conn:send(e);
elseif e==""then
return t();
elseif e==nil then
if o then
self:terminate();
end
self.transport.conn:unhook("drained",t);
a=nil;
end
end
self.transport.conn:hook("drained",t);
t();
end
function t:set_sink(t)
self.transport.conn:hook("incoming-raw",t);
self.transport.conn:hook("disconnected",function(e)
self.stream:debug("Closing sink...");
local e=e.reason;
if e=="closed"then e=nil;end
t(nil,e);
end);
end
end)
package.preload['verse.plugins.jingle_ft']=(function(...)
local o=require"ltn12";
local s=package.config:sub(1,1);
local a="urn:xmpp:jingle:apps:file-transfer:1";
local i="http://jabber.org/protocol/si/profile/file-transfer";
function verse.plugins.jingle_ft(t)
t:hook("ready",function()
t:add_disco_feature(a);
end,10);
local n={type="file"};
function n:generate_accept(t,e)
if e and e.save_file then
self.jingle:hook("connected",function()
local e=o.sink.file(io.open(e.save_file,"w+"));
self.jingle:set_sink(e);
end);
end
return t;
end
local n={__index=n};
t:hook("jingle/content/"..a,function(t,e)
local e=e:get_child("offer"):get_child("file",i);
local e={
name=e.attr.name;
size=tonumber(e.attr.size);
};
return setmetatable({jingle=t,file=e},n);
end);
t:hook("jingle/describe/file",function(e)
local t;
if e.timestamp then
t=os.date("!%Y-%m-%dT%H:%M:%SZ",e.timestamp);
end
return verse.stanza("description",{xmlns=a})
:tag("offer")
:tag("file",{xmlns=i,
name=e.filename,
size=e.size,
date=t,
hash=e.hash,
})
:tag("desc"):text(e.description or"");
end);
function t:send_file(a,t)
local e,i=io.open(t);
if not e then return e,i;end
local i=e:seek("end",0);
e:seek("set",0);
local o=o.source.file(e);
local e=self:jingle(a);
e:offer("file",{
filename=t:match("[^"..s.."]+$");
size=i;
});
e:hook("connected",function()
e:set_source(o,true);
end);
return e;
end
end
end)
package.preload['verse.plugins.jingle_s5b']=(function(...)
local a="urn:xmpp:jingle:transports:s5b:1";
local h=require"util.sha1".sha1;
local r=require"util.uuid".generate;
local function d(e,i)
local function n()
e:unhook("connected",n);
return true;
end
local function s(t)
e:unhook("incoming-raw",s);
if t:sub(1,2)~="\005\000"then
return e:event("error","connection-failure");
end
e:event("connected");
return true;
end
local function a(o)
e:unhook("incoming-raw",a);
if o~="\005\000"then
local t="version-mismatch";
if o:sub(1,1)=="\005"then
t="authentication-failure";
end
return e:event("error",t);
end
e:send(string.char(5,1,0,3,#i)..i.."\0\0");
e:hook("incoming-raw",s,100);
return true;
end
e:hook("connected",n,200);
e:hook("incoming-raw",a,100);
e:send("\005\001\000");
end
local function n(a,e,i)
local e=verse.new(nil,{
streamhosts=e,
current_host=0;
});
local function t(o)
if o then
return a(nil,o.reason);
end
if e.current_host<#e.streamhosts then
e.current_host=e.current_host+1;
e:debug("Attempting to connect to "..e.streamhosts[e.current_host].host..":"..e.streamhosts[e.current_host].port.."...");
local a,t=e:connect(
e.streamhosts[e.current_host].host,
e.streamhosts[e.current_host].port
);
if not a then
e:debug("Error connecting to proxy (%s:%s): %s",
e.streamhosts[e.current_host].host,
e.streamhosts[e.current_host].port,
t
);
else
e:debug("Connecting...");
end
d(e,i);
return true;
end
e:unhook("disconnected",t);
return a(nil);
end
e:hook("disconnected",t,100);
e:hook("connected",function()
e:unhook("disconnected",t);
a(e.streamhosts[e.current_host],e);
end,100);
t();
return e;
end
function verse.plugins.jingle_s5b(e)
e:hook("ready",function()
e:add_disco_feature(a);
end,10);
local t={};
function t:generate_initiate()
self.s5b_sid=r();
local o=verse.stanza("transport",{xmlns=a,
mode="tcp",sid=self.s5b_sid});
local t=0;
for i,a in pairs(e.proxy65.available_streamhosts)do
t=t+1;
o:tag("candidate",{jid=i,host=a.host,
port=a.port,cid=i,priority=t,type="proxy"}):up();
end
e:debug("Have %d proxies",t)
return o;
end
function t:generate_accept(e)
local t={};
self.s5b_peer_candidates=t;
self.s5b_mode=e.attr.mode or"tcp";
self.s5b_sid=e.attr.sid or self.jingle.sid;
for e in e:childtags()do
t[e.attr.cid]={
type=e.attr.type;
jid=e.attr.jid;
host=e.attr.host;
port=tonumber(e.attr.port)or 0;
priority=tonumber(e.attr.priority)or 0;
cid=e.attr.cid;
};
end
local e=verse.stanza("transport",{xmlns=a});
return e;
end
function t:connect(o)
e:warn("Connecting!");
local t={};
for a,e in pairs(self.s5b_peer_candidates or{})do
t[#t+1]=e;
end
if#t>0 then
self.connecting_peer_candidates=true;
local function i(t,e)
self.jingle:send_command("transport-info",verse.stanza("content",{creator=self.creator,name=self.name})
:tag("transport",{xmlns=a,sid=self.s5b_sid})
:tag("candidate-used",{cid=t.cid}));
self.onconnect_callback=o;
self.conn=e;
end
local e=h(self.s5b_sid..self.peer..e.jid,true);
n(i,t,e);
else
e:warn("Actually, I'm going to wait for my peer to tell me its streamhost...");
self.onconnect_callback=o;
end
end
function t:info_received(t)
e:warn("Info received");
local i=t:child_with_name("content");
local o=i:child_with_name("transport");
if o:get_child("candidate-used")and not self.connecting_peer_candidates then
local t=o:child_with_name("candidate-used");
if t then
local function o(o,e)
if self.jingle.role=="initiator"then
self.jingle.stream:send_iq(verse.iq({to=o.jid,type="set"})
:tag("query",{xmlns=xmlns_bytestreams,sid=self.s5b_sid})
:tag("activate"):text(self.jingle.peer),function(o)
if o.attr.type=="result"then
self.jingle:send_command("transport-info",verse.stanza("content",i.attr)
:tag("transport",{xmlns=a,sid=self.s5b_sid})
:tag("activated",{cid=t.attr.cid}));
self.conn=e;
self.onconnect_callback(e);
else
self.jingle.stream:error("Failed to activate bytestream");
end
end);
end
end
self.jingle.stream:debug("CID: %s",self.jingle.stream.proxy65.available_streamhosts[t.attr.cid]);
local t={
self.jingle.stream.proxy65.available_streamhosts[t.attr.cid];
};
local e=h(self.s5b_sid..e.jid..self.peer,true);
n(o,t,e);
end
elseif o:get_child("activated")then
self.onconnect_callback(self.conn);
end
end
function t:disconnect()
if self.conn then
self.conn:close();
end
end
function t:handle_accepted(e)
end
local t={__index=t};
e:hook("jingle/transport/"..a,function(e)
return setmetatable({
role=e.role,
peer=e.peer,
stream=e.stream,
jingle=e,
},t);
end);
end
end)
package.preload['verse.plugins.disco']=(function(...)
local a=require"util.stanza"
local o=require("mime").b64
local i=require("util.sha1").sha1
local e="http://jabber.org/protocol/disco";
local n=e.."#info";
local h=e.."#items";
function verse.plugins.disco(e)
e.disco={cache={},info={}}
e.disco.info.identities={
{category='client',type='pc',name='Verse'},
}
e.disco.info.features={
{var='http://jabber.org/protocol/caps'},
{var='http://jabber.org/protocol/disco#info'},
{var='http://jabber.org/protocol/disco#items'},
}
e.disco.items={}
e.disco.nodes={}
e.caps={}
e.caps.node='http://code.matthewwild.co.uk/verse/'
local function r(t,e)
if t.category<e.category then
return true;
elseif e.category<t.category then
return false;
end
if t.type<e.type then
return true;
elseif e.type<t.type then
return false;
end
if(not t['xml:lang']and e['xml:lang'])or
(e['xml:lang']and t['xml:lang']<e['xml:lang'])then
return true
end
return false
end
local function t(e,t)
return e.var<t.var
end
local function s()
table.sort(e.disco.info.identities,r)
table.sort(e.disco.info.features,t)
local t=''
for a,e in pairs(e.disco.info.identities)do
t=t..string.format(
'%s/%s/%s/%s',e.category,e.type,
e['xml:lang']or'',e.name or''
)..'<'
end
for a,e in pairs(e.disco.info.features)do
t=t..e.var..'<'
end
return(o(i(t)))
end
setmetatable(e.caps,{
__call=function(...)
local t=s()
return a.stanza('c',{
xmlns='http://jabber.org/protocol/caps',
hash='sha-1',
node=e.caps.node,
ver=t
})
end
})
function e:add_disco_feature(e)
table.insert(self.disco.info.features,{var=e});
end
function e:remove_disco_feature(e)
for t,a in ipairs(self.disco.info.features)do
if a.var==e then
table.remove(self.disco.info.features,t);
return true;
end
end
end
function e:add_disco_item(a,t)
local e=self.disco.items;
if t then
e=self.disco.nodes[t];
if not e then
e={features={},items={}};
self.disco.nodes[t]=e;
e=e.items;
else
e=e.items;
end
end
table.insert(e,a);
end
function e:jid_has_identity(a,e,t)
local o=self.disco.cache[a];
if not o then
return nil,"no-cache";
end
local a=self.disco.cache[a].identities;
if t then
return a[e.."/"..t]or false;
end
for t in pairs(a)do
if t:match("^(.*)/")==e then
return true;
end
end
end
function e:jid_supports(e,t)
local e=self.disco.cache[e];
if not e or not e.features then
return nil,"no-cache";
end
return e.features[t]or false;
end
function e:get_local_services(a,o)
local e=self.disco.cache[self.host];
if not(e)or not(e.items)then
return nil,"no-cache";
end
local t={};
for i,e in ipairs(e.items)do
if self:jid_has_identity(e.jid,a,o)then
table.insert(t,e.jid);
end
end
return t;
end
function e:disco_local_services(a)
self:disco_items(self.host,nil,function(t)
local e=0;
local function o()
e=e-1;
if e==0 then
return a(t);
end
end
for a,t in ipairs(t)do
if t.jid then
e=e+1;
self:disco_info(t.jid,nil,o);
end
end
if e==0 then
return a(t);
end
end);
end
function e:disco_info(e,t,s)
local a=verse.iq({to=e,type="get"})
:tag("query",{xmlns=n,node=t});
self:send_iq(a,function(a)
if a.attr.type=="error"then
return s(nil,a:get_error());
end
local o,i={},{};
for e in a:get_child("query",n):childtags()do
if e.name=="identity"then
o[e.attr.category.."/"..e.attr.type]=e.attr.name or true;
elseif e.name=="feature"then
i[e.attr.var]=true;
end
end
if not self.disco.cache[e]then
self.disco.cache[e]={nodes={}};
end
if t then
if not self.disco.cache[e].nodes[t]then
self.disco.cache[e].nodes[t]={nodes={}};
end
self.disco.cache[e].nodes[t].identities=o;
self.disco.cache[e].nodes[t].features=i;
else
self.disco.cache[e].identities=o;
self.disco.cache[e].features=i;
end
return s(self.disco.cache[e]);
end);
end
function e:disco_items(t,a,i)
local o=verse.iq({to=t,type="get"})
:tag("query",{xmlns=h,node=a});
self:send_iq(o,function(o)
if o.attr.type=="error"then
return i(nil,o:get_error());
end
local e={};
for t in o:get_child("query",h):childtags()do
if t.name=="item"then
table.insert(e,{
name=t.attr.name;
jid=t.attr.jid;
node=t.attr.node;
});
end
end
if not self.disco.cache[t]then
self.disco.cache[t]={nodes={}};
end
if a then
if not self.disco.cache[t].nodes[a]then
self.disco.cache[t].nodes[a]={nodes={}};
end
self.disco.cache[t].nodes[a].items=e;
else
self.disco.cache[t].items=e;
end
return i(e);
end);
end
e:hook("iq/http://jabber.org/protocol/disco#info",function(t)
if t.attr.type=='get'then
local o=t:child_with_name('query')
if not o then return;end
local i
local n
if o.attr.node then
local h=s()
local s=e.disco.nodes[o.attr.node]
if s and s.info then
i=s.info.identities or{}
n=s.info.identities or{}
elseif o.attr.node==e.caps.node..'#'..h then
i=e.disco.info.identities
n=e.disco.info.features
else
local t=a.stanza('iq',{
to=t.attr.from,
from=t.attr.to,
id=t.attr.id,
type='error'
})
t:tag('query',{xmlns='http://jabber.org/protocol/disco#info'}):reset()
t:tag('error',{type='cancel'}):tag(
'item-not-found',{xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'}
)
e:send(t)
return true
end
else
i=e.disco.info.identities
n=e.disco.info.features
end
local o=a.stanza('query',{
xmlns='http://jabber.org/protocol/disco#info',
node=o.attr.node
})
for t,e in pairs(i)do
o:tag('identity',e):reset()
end
for a,t in pairs(n)do
o:tag('feature',t):reset()
end
e:send(a.stanza('iq',{
to=t.attr.from,
from=t.attr.to,
id=t.attr.id,
type='result'
}):add_child(o))
return true
end
end);
e:hook("iq/http://jabber.org/protocol/disco#items",function(t)
if t.attr.type=='get'then
local o=t:child_with_name('query')
if not o then return;end
local i
if o.attr.node then
local o=e.disco.nodes[o.attr.node]
if o then
i=o.items or{}
else
local t=a.stanza('iq',{
to=t.attr.from,
from=t.attr.to,
id=t.attr.id,
type='error'
})
t:tag('query',{xmlns='http://jabber.org/protocol/disco#items'}):reset()
t:tag('error',{type='cancel'}):tag(
'item-not-found',{xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'}
)
e:send(t)
return true
end
else
i=e.disco.items
end
local o=a.stanza('query',{
xmlns='http://jabber.org/protocol/disco#items',
node=o.attr.node
})
for a,t in pairs(i)do
o:tag('item',t):reset()
end
e:send(a.stanza('iq',{
to=t.attr.from,
from=t.attr.to,
id=t.attr.id,
type='result'
}):add_child(o))
return true
end
end);
local t;
e:hook("ready",function()
if t then return;end
t=true;
e:disco_local_services(function(t)
for a,t in ipairs(t)do
local a=e.disco.cache[t.jid];
if a then
for a in pairs(a.identities)do
local a,o=a:match("^(.*)/(.*)$");
e:event("disco/service-discovered/"..a,{
type=o,jid=t.jid;
});
end
end
end
e:event("ready");
end);
return true;
end,5);
end
end)
package.preload['verse.plugins.pep']=(function(...)
local a="http://jabber.org/protocol/pubsub";
local o=a.."#event";
function verse.plugins.pep(e)
e.pep={};
e:hook("message",function(a)
local t=a:get_child("event",o);
if not t then return;end
local t=t:get_child("items");
if not t then return;end
local i=t.attr.node;
for t in t:childtags()do
if t.name=="item"and t.attr.xmlns==o then
e:event("pep/"..i,{
from=a.attr.from,
item=t.tags[1],
});
end
end
end);
function e:hook_pep(t,a,o)
e:hook("pep/"..t,a,o);
e:add_disco_feature(t.."+notify");
end
function e:unhook_pep(t,a)
e:unhook("pep/"..t,a);
local a=e.events._handlers["pep/"..t];
if not(a)or#a==0 then
e:remove_disco_feature(t.."+notify");
end
end
function e:publish_pep(t,o)
local t=verse.iq({type="set"})
:tag("pubsub",{xmlns=a})
:tag("publish",{node=o or t.attr.xmlns})
:tag("item")
:add_child(t);
return e:send_iq(t);
end
end
end)
package.preload['verse.plugins.adhoc']=(function(...)
local n=require"lib.adhoc";
local t="http://jabber.org/protocol/commands";
local s="jabber:x:data";
local a={};
a.__index=a;
local o={};
function verse.plugins.adhoc(e)
e:add_disco_feature(t);
function e:query_commands(a,o)
e:disco_items(a,t,function(a)
e:debug("adhoc list returned")
local t={};
for o,a in ipairs(a)do
t[a.node]=a.name;
end
e:debug("adhoc calling callback")
return o(t);
end);
end
function e:execute_command(t,o,i)
local e=setmetatable({
stream=e,jid=t,
command=o,callback=i
},a);
return e:execute();
end
local function r(t,e)
if not(e)or e=="user"then return true;end
if type(e)=="function"then
return e(t);
end
end
function e:add_adhoc_command(i,a,h,s)
o[a]=n.new(i,a,h,s);
e:add_disco_item({jid=e.jid,node=a,name=i},t);
return o[a];
end
local function i(a)
local t=a.tags[1];
local t=t.attr.node;
local t=o[t];
if not t then return;end
if not r(a.attr.from,t.permission)then
e:send(verse.error_reply(a,"auth","forbidden","You don't have permission to execute this command"):up()
:add_child(t:cmdtag("canceled")
:tag("note",{type="error"}):text("You don't have permission to execute this command")));
return true
end
return n.handle_cmd(t,{send=function(t)return e:send(t)end},a);
end
e:hook("iq/"..t,function(e)
local a=e.attr.type;
local t=e.tags[1].name;
if a=="set"and t=="command"then
return i(e);
end
end);
end
function a:_process_response(e)
if e.type=="error"then
self.status="canceled";
self.callback(self,{});
end
local e=e:get_child("command",t);
self.status=e.attr.status;
self.sessionid=e.attr.sessionid;
self.form=e:get_child("x",s);
self.callback(self);
end
function a:execute()
local e=verse.iq({to=self.jid,type="set"})
:tag("command",{xmlns=t,node=self.command});
self.stream:send_iq(e,function(e)
self:_process_response(e);
end);
end
function a:next(a)
local e=verse.iq({to=self.jid,type="set"})
:tag("command",{
xmlns=t,
node=self.command,
sessionid=self.sessionid
});
if a then e:add_child(a);end
self.stream:send_iq(e,function(e)
self:_process_response(e);
end);
end
end)
package.preload['net.httpclient_listener']=(function(...)
local o=require"util.logger".init("httpclient_listener");
local n=require"net.connlisteners".register;
local t={};
local e={};
local e={default_port=80,default_mode="*a"};
function e.onincoming(a,i)
local e=t[a];
if not e then
o("warn","Received response from connection %s with no request attached!",tostring(a));
return;
end
if i and e.reader then
e:reader(i);
end
end
function e.ondisconnect(a,o)
local e=t[a];
if e and o~="closed"then
e:reader(nil);
end
t[a]=nil;
end
function e.register_request(a,e)
o("debug","Attaching request %s to connection %s",tostring(e.id or e),tostring(a));
t[a]=e;
end
n("httpclient",e);
end)
package.preload['net.connlisteners']=(function(...)
local s=(CFG_SOURCEDIR or".").."/net/";
local r=require"net.server";
local o=require"util.logger".init("connlisteners");
local i=tostring;
local h,d,n=
dofile,pcall,error
module"connlisteners"
local e={};
function register(t,a)
if e[t]and e[t]~=a then
o("debug","Listener %s is already registered, not registering any more",t);
return false;
end
e[t]=a;
o("debug","Registered connection listener %s",t);
return true;
end
function deregister(t)
e[t]=nil;
end
function get(t)
local a=e[t];
if not a then
local s,n=d(h,s..t:gsub("[^%w%-]","_").."_listener.lua");
if not s then
o("error","Error while loading listener '%s': %s",i(t),i(n));
return nil,n;
end
a=e[t];
end
return a;
end
function start(a,e)
local t,o=get(a);
if not t then
n("No such connection module: "..a..(o and(" ("..o..")")or""),0);
end
local i=(e and e.interface)or t.default_interface or"*";
local n=(e and e.port)or t.default_port or n("Can't start listener "..a.." because no port was specified, and it has no default port",0);
local o=(e and e.mode)or t.default_mode or 1;
local a=(e and e.ssl)or nil;
local e=e and e.type=="ssl";
if e and not a then
return nil,"no ssl context";
end
return r.addserver(i,n,t,o,e and a or nil);
end
return _M;
end)
package.preload['net.http']=(function(...)
local b=require"socket"
local v=require"mime"
local s=require"socket.url"
local n=require"util.httpstream".new;
local w=require"net.server"
local e=require"net.connlisteners".get;
local d=e("httpclient")or error("No httpclient listener!");
local r,i=table.insert,table.concat;
local h,o=pairs,ipairs;
local a,u,m,f,y,c,t=
tonumber,tostring,xpcall,select,debug.traceback,string.char,string.format;
local l=require"util.logger".init("http");
module"http"
function urlencode(e)return e and(e:gsub("%W",function(e)return t("%%%02x",e:byte());end));end
function urldecode(e)return e and(e:gsub("%%(%x%x)",function(e)return c(a(e,16));end));end
local function e(e)
return e and(e:gsub("%W",function(e)
if e~=" "then
return t("%%%02x",e:byte());
else
return"+";
end
end));
end
function formencode(t)
local a={};
for o,t in o(t)do
r(a,e(t.name).."="..e(t.value));
end
return i(a,"&");
end
local function p(e,i,t)
if not e.parser then
local function o(t)
if e.callback then
for t,a in h(t)do e[t]=a;end
e.callback(t.body,t.code,e);
e.callback=nil;
end
destroy_request(e);
end
local function a(t)
if e.callback then
e.callback(t or"connection-closed",0,e);
e.callback=nil;
end
destroy_request(e);
end
local function t()
return e;
end
e.parser=n(o,a,"client",t);
end
e.parser:feed(i);
end
local function c(e)l("error","Traceback[http]: %s: %s",u(e),y());end
function request(e,t,n)
local e=s.parse(e);
if not(e and e.host)then
n(nil,0,e);
return nil,"invalid-url";
end
if not e.path then
e.path="/";
end
local s,o;
local a={["Host"]=e.host,["User-Agent"]="Prosody XMPP Server"}
if e.userinfo then
a["Authorization"]="Basic "..v.b64(e.userinfo);
end
if t then
s=t.headers;
e.onlystatus=t.onlystatus;
o=t.body;
if o then
e.method="POST ";
a["Content-Length"]=u(#o);
a["Content-Type"]="application/x-www-form-urlencoded";
end
if t.method then e.method=t.method;end
end
e.handler,e.conn=w.wrapclient(b.tcp(),e.host,e.port or 80,d,"*a");
e.write=function(...)return e.handler:write(...);end
e.conn:settimeout(0);
local u,t=e.conn:connect(e.host,e.port or 80);
if not u and t~="timeout"then
n(nil,0,e);
return nil,t;
end
local t={e.method or"GET"," ",e.path," HTTP/1.1\r\n"};
if e.query then
r(t,4,"?");
r(t,5,e.query);
end
e.write(i(t));
local t={[2]=": ",[4]="\r\n"};
if s then
for o,n in h(s)do
t[1],t[3]=o,n;
e.write(i(t));
a[o]=nil;
end
end
for o,n in h(a)do
t[1],t[3]=o,n;
e.write(i(t));
a[o]=nil;
end
e.write("\r\n");
if o then
e.write(o);
end
e.callback=function(a,t,o)l("debug","Calling callback, status %s",t or"---");return f(2,m(function()return n(a,t,o)end,c));end
e.reader=p;
e.state="status";
d.register_request(e.handler,e);
return e;
end
function destroy_request(e)
if e.conn then
e.conn=nil;
e.handler:close()
d.ondisconnect(e.handler,"closed");
end
end
_M.urlencode=urlencode;
return _M;
end)
package.preload['verse.bosh']=(function(...)
local n=require"core.xmlhandlers";
local o=require"util.stanza";
require"net.httpclient_listener";
local i=require"net.http";
local e=setmetatable({},{__index=verse.stream_mt});
e.__index=e;
local s="http://etherx.jabber.org/streams";
local h="http://jabber.org/protocol/httpbind";
local a=5;
function verse.new_bosh(a,t)
local t={
bosh_conn_pool={};
bosh_waiting_requests={};
bosh_rid=math.random(1,999999);
bosh_outgoing_buffer={};
bosh_url=t;
conn={};
};
function t:reopen()
self.bosh_need_restart=true;
self:flush();
end
local t=verse.new(a,t);
return setmetatable(t,e);
end
function e:connect()
self:_send_session_request();
end
function e:send(e)
self:debug("Putting into BOSH send buffer: %s",tostring(e));
self.bosh_outgoing_buffer[#self.bosh_outgoing_buffer+1]=o.clone(e);
self:flush();
end
function e:flush()
if self.connected
and#self.bosh_waiting_requests<self.bosh_max_requests
and(#self.bosh_waiting_requests==0
or#self.bosh_outgoing_buffer>0
or self.bosh_need_restart)then
self:debug("Flushing...");
local e=self:_make_body();
local t=self.bosh_outgoing_buffer;
for o,a in ipairs(t)do
e:add_child(a);
t[o]=nil;
end
self:_make_request(e);
else
self:debug("Decided not to flush.");
end
end
function e:_make_request(o)
local e,t=i.request(self.bosh_url,{body=tostring(o)},function(i,e,t)
if e~=0 then
self.inactive_since=nil;
return self:_handle_response(i,e,t);
end
local e=os.time();
if not self.inactive_since then
self.inactive_since=e;
elseif e-self.inactive_since>self.bosh_max_inactivity then
return self:_disconnected();
else
self:debug("%d seconds left to reconnect, retrying in %d seconds...",
self.bosh_max_inactivity-(e-self.inactive_since),a);
end
timer.add_task(a,function()
self:debug("Retrying request...");
for e,a in ipairs(self.bosh_waiting_requests)do
if a==t then
table.remove(self.bosh_waiting_requests,e);
break;
end
end
self:_make_request(o);
end);
end);
if e then
table.insert(self.bosh_waiting_requests,e);
else
self:warn("Request failed instantly: %s",t);
end
end
function e:_disconnected()
self.connected=nil;
self:event("disconnected");
end
function e:_send_session_request()
local e=self:_make_body();
e.attr.hold="1";
e.attr.wait="60";
e.attr["xml:lang"]="en";
e.attr.ver="1.6";
e.attr.from=self.jid;
e.attr.to=self.host;
e.attr.secure='true';
i.request(self.bosh_url,{body=tostring(e)},function(e,t)
if t==0 then
return self:_disconnected();
end
local e=self:_parse_response(e)
if not e then
self:warn("Invalid session creation response");
self:_disconnected();
return;
end
self.bosh_sid=e.attr.sid;
self.bosh_wait=tonumber(e.attr.wait);
self.bosh_hold=tonumber(e.attr.hold);
self.bosh_max_inactivity=tonumber(e.attr.inactivity);
self.bosh_max_requests=tonumber(e.attr.requests)or self.bosh_hold;
self.connected=true;
self:event("connected");
self:_handle_response_payload(e);
end);
end
function e:_handle_response(o,t,e)
if self.bosh_waiting_requests[1]~=e then
self:warn("Server replied to request that wasn't the oldest");
for t,a in ipairs(self.bosh_waiting_requests)do
if a==e then
self.bosh_waiting_requests[t]=nil;
break;
end
end
else
table.remove(self.bosh_waiting_requests,1);
end
local e=self:_parse_response(o);
if e then
self:_handle_response_payload(e);
end
self:flush();
end
function e:_handle_response_payload(t)
for e in t:childtags()do
if e.attr.xmlns==s then
self:event("stream-"..e.name,e);
elseif e.attr.xmlns then
self:event("stream/"..e.attr.xmlns,e);
else
self:event("stanza",e);
end
end
if t.attr.type=="terminate"then
self:_disconnected({reason=t.attr.condition});
end
end
local a={
stream_ns="http://jabber.org/protocol/httpbind",stream_tag="body",
default_ns="jabber:client",
streamopened=function(e,t)e.notopen=nil;e.payload=verse.stanza("body",t);return true;end;
handlestanza=function(t,e)t.payload:add_child(e);end;
};
function e:_parse_response(e)
self:debug("Parsing response: %s",e);
if e==nil then
self:debug("%s",debug.traceback());
self:_disconnected();
return;
end
local t={notopen=true,log=self.log};
local a=lxp.new(n(t,a),"\1");
a:parse(e);
return t.payload;
end
function e:_make_body()
self.bosh_rid=self.bosh_rid+1;
local e=verse.stanza("body",{
xmlns=h;
content="text/xml; charset=utf-8";
sid=self.bosh_sid;
rid=self.bosh_rid;
});
if self.bosh_need_restart then
self.bosh_need_restart=nil;
e.attr.restart='true';
end
return e;
end
end)
package.preload['bit']=(function(...)
local o=type;
local s=tonumber;
local i=setmetatable;
local d=error;
local r=tostring;
local e=print;
local c={[0]=0;[1]=1;[2]=2;[3]=3;[4]=4;[5]=5;[6]=6;[7]=7;[8]=8;[9]=9;[10]=10;[11]=11;[12]=12;[13]=13;[14]=14;[15]=15;[16]=1;[17]=0;[18]=3;[19]=2;[20]=5;[21]=4;[22]=7;[23]=6;[24]=9;[25]=8;[26]=11;[27]=10;[28]=13;[29]=12;[30]=15;[31]=14;[32]=2;[33]=3;[34]=0;[35]=1;[36]=6;[37]=7;[38]=4;[39]=5;[40]=10;[41]=11;[42]=8;[43]=9;[44]=14;[45]=15;[46]=12;[47]=13;[48]=3;[49]=2;[50]=1;[51]=0;[52]=7;[53]=6;[54]=5;[55]=4;[56]=11;[57]=10;[58]=9;[59]=8;[60]=15;[61]=14;[62]=13;[63]=12;[64]=4;[65]=5;[66]=6;[67]=7;[68]=0;[69]=1;[70]=2;[71]=3;[72]=12;[73]=13;[74]=14;[75]=15;[76]=8;[77]=9;[78]=10;[79]=11;[80]=5;[81]=4;[82]=7;[83]=6;[84]=1;[85]=0;[86]=3;[87]=2;[88]=13;[89]=12;[90]=15;[91]=14;[92]=9;[93]=8;[94]=11;[95]=10;[96]=6;[97]=7;[98]=4;[99]=5;[100]=2;[101]=3;[102]=0;[103]=1;[104]=14;[105]=15;[106]=12;[107]=13;[108]=10;[109]=11;[110]=8;[111]=9;[112]=7;[113]=6;[114]=5;[115]=4;[116]=3;[117]=2;[118]=1;[119]=0;[120]=15;[121]=14;[122]=13;[123]=12;[124]=11;[125]=10;[126]=9;[127]=8;[128]=8;[129]=9;[130]=10;[131]=11;[132]=12;[133]=13;[134]=14;[135]=15;[136]=0;[137]=1;[138]=2;[139]=3;[140]=4;[141]=5;[142]=6;[143]=7;[144]=9;[145]=8;[146]=11;[147]=10;[148]=13;[149]=12;[150]=15;[151]=14;[152]=1;[153]=0;[154]=3;[155]=2;[156]=5;[157]=4;[158]=7;[159]=6;[160]=10;[161]=11;[162]=8;[163]=9;[164]=14;[165]=15;[166]=12;[167]=13;[168]=2;[169]=3;[170]=0;[171]=1;[172]=6;[173]=7;[174]=4;[175]=5;[176]=11;[177]=10;[178]=9;[179]=8;[180]=15;[181]=14;[182]=13;[183]=12;[184]=3;[185]=2;[186]=1;[187]=0;[188]=7;[189]=6;[190]=5;[191]=4;[192]=12;[193]=13;[194]=14;[195]=15;[196]=8;[197]=9;[198]=10;[199]=11;[200]=4;[201]=5;[202]=6;[203]=7;[204]=0;[205]=1;[206]=2;[207]=3;[208]=13;[209]=12;[210]=15;[211]=14;[212]=9;[213]=8;[214]=11;[215]=10;[216]=5;[217]=4;[218]=7;[219]=6;[220]=1;[221]=0;[222]=3;[223]=2;[224]=14;[225]=15;[226]=12;[227]=13;[228]=10;[229]=11;[230]=8;[231]=9;[232]=6;[233]=7;[234]=4;[235]=5;[236]=2;[237]=3;[238]=0;[239]=1;[240]=15;[241]=14;[242]=13;[243]=12;[244]=11;[245]=10;[246]=9;[247]=8;[248]=7;[249]=6;[250]=5;[251]=4;[252]=3;[253]=2;[254]=1;[255]=0;};
local m={[0]=0;[1]=1;[2]=2;[3]=3;[4]=4;[5]=5;[6]=6;[7]=7;[8]=8;[9]=9;[10]=10;[11]=11;[12]=12;[13]=13;[14]=14;[15]=15;[16]=1;[17]=1;[18]=3;[19]=3;[20]=5;[21]=5;[22]=7;[23]=7;[24]=9;[25]=9;[26]=11;[27]=11;[28]=13;[29]=13;[30]=15;[31]=15;[32]=2;[33]=3;[34]=2;[35]=3;[36]=6;[37]=7;[38]=6;[39]=7;[40]=10;[41]=11;[42]=10;[43]=11;[44]=14;[45]=15;[46]=14;[47]=15;[48]=3;[49]=3;[50]=3;[51]=3;[52]=7;[53]=7;[54]=7;[55]=7;[56]=11;[57]=11;[58]=11;[59]=11;[60]=15;[61]=15;[62]=15;[63]=15;[64]=4;[65]=5;[66]=6;[67]=7;[68]=4;[69]=5;[70]=6;[71]=7;[72]=12;[73]=13;[74]=14;[75]=15;[76]=12;[77]=13;[78]=14;[79]=15;[80]=5;[81]=5;[82]=7;[83]=7;[84]=5;[85]=5;[86]=7;[87]=7;[88]=13;[89]=13;[90]=15;[91]=15;[92]=13;[93]=13;[94]=15;[95]=15;[96]=6;[97]=7;[98]=6;[99]=7;[100]=6;[101]=7;[102]=6;[103]=7;[104]=14;[105]=15;[106]=14;[107]=15;[108]=14;[109]=15;[110]=14;[111]=15;[112]=7;[113]=7;[114]=7;[115]=7;[116]=7;[117]=7;[118]=7;[119]=7;[120]=15;[121]=15;[122]=15;[123]=15;[124]=15;[125]=15;[126]=15;[127]=15;[128]=8;[129]=9;[130]=10;[131]=11;[132]=12;[133]=13;[134]=14;[135]=15;[136]=8;[137]=9;[138]=10;[139]=11;[140]=12;[141]=13;[142]=14;[143]=15;[144]=9;[145]=9;[146]=11;[147]=11;[148]=13;[149]=13;[150]=15;[151]=15;[152]=9;[153]=9;[154]=11;[155]=11;[156]=13;[157]=13;[158]=15;[159]=15;[160]=10;[161]=11;[162]=10;[163]=11;[164]=14;[165]=15;[166]=14;[167]=15;[168]=10;[169]=11;[170]=10;[171]=11;[172]=14;[173]=15;[174]=14;[175]=15;[176]=11;[177]=11;[178]=11;[179]=11;[180]=15;[181]=15;[182]=15;[183]=15;[184]=11;[185]=11;[186]=11;[187]=11;[188]=15;[189]=15;[190]=15;[191]=15;[192]=12;[193]=13;[194]=14;[195]=15;[196]=12;[197]=13;[198]=14;[199]=15;[200]=12;[201]=13;[202]=14;[203]=15;[204]=12;[205]=13;[206]=14;[207]=15;[208]=13;[209]=13;[210]=15;[211]=15;[212]=13;[213]=13;[214]=15;[215]=15;[216]=13;[217]=13;[218]=15;[219]=15;[220]=13;[221]=13;[222]=15;[223]=15;[224]=14;[225]=15;[226]=14;[227]=15;[228]=14;[229]=15;[230]=14;[231]=15;[232]=14;[233]=15;[234]=14;[235]=15;[236]=14;[237]=15;[238]=14;[239]=15;[240]=15;[241]=15;[242]=15;[243]=15;[244]=15;[245]=15;[246]=15;[247]=15;[248]=15;[249]=15;[250]=15;[251]=15;[252]=15;[253]=15;[254]=15;[255]=15;};
local p={[0]=0;[1]=0;[2]=0;[3]=0;[4]=0;[5]=0;[6]=0;[7]=0;[8]=0;[9]=0;[10]=0;[11]=0;[12]=0;[13]=0;[14]=0;[15]=0;[16]=0;[17]=1;[18]=0;[19]=1;[20]=0;[21]=1;[22]=0;[23]=1;[24]=0;[25]=1;[26]=0;[27]=1;[28]=0;[29]=1;[30]=0;[31]=1;[32]=0;[33]=0;[34]=2;[35]=2;[36]=0;[37]=0;[38]=2;[39]=2;[40]=0;[41]=0;[42]=2;[43]=2;[44]=0;[45]=0;[46]=2;[47]=2;[48]=0;[49]=1;[50]=2;[51]=3;[52]=0;[53]=1;[54]=2;[55]=3;[56]=0;[57]=1;[58]=2;[59]=3;[60]=0;[61]=1;[62]=2;[63]=3;[64]=0;[65]=0;[66]=0;[67]=0;[68]=4;[69]=4;[70]=4;[71]=4;[72]=0;[73]=0;[74]=0;[75]=0;[76]=4;[77]=4;[78]=4;[79]=4;[80]=0;[81]=1;[82]=0;[83]=1;[84]=4;[85]=5;[86]=4;[87]=5;[88]=0;[89]=1;[90]=0;[91]=1;[92]=4;[93]=5;[94]=4;[95]=5;[96]=0;[97]=0;[98]=2;[99]=2;[100]=4;[101]=4;[102]=6;[103]=6;[104]=0;[105]=0;[106]=2;[107]=2;[108]=4;[109]=4;[110]=6;[111]=6;[112]=0;[113]=1;[114]=2;[115]=3;[116]=4;[117]=5;[118]=6;[119]=7;[120]=0;[121]=1;[122]=2;[123]=3;[124]=4;[125]=5;[126]=6;[127]=7;[128]=0;[129]=0;[130]=0;[131]=0;[132]=0;[133]=0;[134]=0;[135]=0;[136]=8;[137]=8;[138]=8;[139]=8;[140]=8;[141]=8;[142]=8;[143]=8;[144]=0;[145]=1;[146]=0;[147]=1;[148]=0;[149]=1;[150]=0;[151]=1;[152]=8;[153]=9;[154]=8;[155]=9;[156]=8;[157]=9;[158]=8;[159]=9;[160]=0;[161]=0;[162]=2;[163]=2;[164]=0;[165]=0;[166]=2;[167]=2;[168]=8;[169]=8;[170]=10;[171]=10;[172]=8;[173]=8;[174]=10;[175]=10;[176]=0;[177]=1;[178]=2;[179]=3;[180]=0;[181]=1;[182]=2;[183]=3;[184]=8;[185]=9;[186]=10;[187]=11;[188]=8;[189]=9;[190]=10;[191]=11;[192]=0;[193]=0;[194]=0;[195]=0;[196]=4;[197]=4;[198]=4;[199]=4;[200]=8;[201]=8;[202]=8;[203]=8;[204]=12;[205]=12;[206]=12;[207]=12;[208]=0;[209]=1;[210]=0;[211]=1;[212]=4;[213]=5;[214]=4;[215]=5;[216]=8;[217]=9;[218]=8;[219]=9;[220]=12;[221]=13;[222]=12;[223]=13;[224]=0;[225]=0;[226]=2;[227]=2;[228]=4;[229]=4;[230]=6;[231]=6;[232]=8;[233]=8;[234]=10;[235]=10;[236]=12;[237]=12;[238]=14;[239]=14;[240]=0;[241]=1;[242]=2;[243]=3;[244]=4;[245]=5;[246]=6;[247]=7;[248]=8;[249]=9;[250]=10;[251]=11;[252]=12;[253]=13;[254]=14;[255]=15;}
local v={[0]=15;[1]=14;[2]=13;[3]=12;[4]=11;[5]=10;[6]=9;[7]=8;[8]=7;[9]=6;[10]=5;[11]=4;[12]=3;[13]=2;[14]=1;[15]=0;};
local u={[0]=0;[1]=0;[2]=1;[3]=1;[4]=2;[5]=2;[6]=3;[7]=3;[8]=4;[9]=4;[10]=5;[11]=5;[12]=6;[13]=6;[14]=7;[15]=7;};
local l={[0]=0;[1]=8;[2]=0;[3]=8;[4]=0;[5]=8;[6]=0;[7]=8;[8]=0;[9]=8;[10]=0;[11]=8;[12]=0;[13]=8;[14]=0;[15]=8;};
local w={[0]=0;[1]=2;[2]=4;[3]=6;[4]=8;[5]=10;[6]=12;[7]=14;[8]=0;[9]=2;[10]=4;[11]=6;[12]=8;[13]=10;[14]=12;[15]=14;};
local y={[0]=0;[1]=0;[2]=0;[3]=0;[4]=0;[5]=0;[6]=0;[7]=0;[8]=1;[9]=1;[10]=1;[11]=1;[12]=1;[13]=1;[14]=1;[15]=1;};
local f={[0]=0;[1]=0;[2]=0;[3]=0;[4]=0;[5]=0;[6]=0;[7]=0;[8]=8;[9]=8;[10]=8;[11]=8;[12]=8;[13]=8;[14]=8;[15]=8;};
module"bit"
local n={__tostring=function(e)return("%x%x%x%x%x%x%x%x"):format(e[1],e[2],e[3],e[4],e[5],e[6],e[7],e[8]);end};
local function h(a,t,e)
return i({
e[a[1]*16+t[1]];
e[a[2]*16+t[2]];
e[a[3]*16+t[3]];
e[a[4]*16+t[4]];
e[a[5]*16+t[5]];
e[a[6]*16+t[6]];
e[a[7]*16+t[7]];
e[a[8]*16+t[8]];
},n);
end
local function a(t,e)
return i({
e[t[1]];
e[t[2]];
e[t[3]];
e[t[4]];
e[t[5]];
e[t[6]];
e[t[7]];
e[t[8]];
},n);
end
function bxor(t,e)return h(t,e,c);end
function bor(e,t)return h(e,t,m);end
function band(t,e)return h(t,e,p);end
function bnot(e)return a(e,v);end
local function h(t)
local a=0;
for e=1,8 do
local o=u[t[e]]+a;
a=l[t[e]];
t[e]=o;
end
end
function rshift(e,t)
local e={e[1],e[2],e[3],e[4],e[5],e[6],e[7],e[8]};
for t=1,t do h(e);end
return i(e,n);
end
local function h(e)
local a=f[e[1]];
for t=1,8 do
local o=u[e[t]]+a;
a=l[e[t]];
e[t]=o;
end
end
function arshift(e,t)
local e={e[1],e[2],e[3],e[4],e[5],e[6],e[7],e[8]};
for t=1,t do h(e);end
return i(e,n);
end
local function h(t)
local a=0;
for e=8,1,-1 do
local o=w[t[e]]+a;
a=y[t[e]];
t[e]=o;
end
end
function lshift(e,t)
local e={e[1],e[2],e[3],e[4],e[5],e[6],e[7],e[8]};
for t=1,t do h(e);end
return i(e,n);
end
local function a(e)
if o(e)=="number"then e=("%x"):format(e);
elseif o(e)=="table"then return e;
elseif o(e)~="string"then d("string expected, got "..o(e),2);end
local a={0,0,0,0,0,0,0,0};
e="00000000"..e;
e=e:sub(-8);
for t=1,8 do
a[t]=s(e:sub(t,t),16)or d("Number format error",2);
end
return i(a,n);
end
local function t(t)
return function(e,...)
if o(e)~="table"then e=a(e);end
e=t(e,...);
e=s(r(e),16);
if e>2147483647 then e=e-1-4294967295;end
return e;
end;
end
local function i(i)
return function(e,t,...)
if o(e)~="table"then e=a(e);end
if o(t)~="table"then t=a(t);end
e=i(e,t,...);
e=s(r(e),16);
if e>2147483647 then e=e-1-4294967295;end
return e;
end;
end
bxor=i(bxor);
bor=i(bor);
band=i(band);
bnot=t(bnot);
lshift=t(lshift);
rshift=t(rshift);
arshift=t(arshift);
cast=t(a);
bits=32;
return _M;
end)
package.preload['verse.client']=(function(...)
local t=require"verse";
local o=t.stream_mt;
local d=require"util.jid".split;
local l=require"net.adns";
local h=require"lxp";
local a=require"util.stanza";
t.message,t.presence,t.iq,t.stanza,t.reply,t.error_reply=
a.message,a.presence,a.iq,a.stanza,a.reply,a.error_reply;
local r=require"core.xmlhandlers";
local n="http://etherx.jabber.org/streams";
local function s(t,e)
return t.priority<e.priority or(t.priority==e.priority and t.weight>e.weight);
end
local i={
stream_ns=n,
stream_tag="stream",
default_ns="jabber:client"};
function i.streamopened(e,t)
e.stream_id=t.id;
if not e:event("opened",t)then
e.notopen=nil;
end
return true;
end
function i.streamclosed(e)
return e:event("closed");
end
function i.handlestanza(t,e)
if e.attr.xmlns==n then
return t:event("stream-"..e.name,e);
elseif e.attr.xmlns then
return t:event("stream/"..e.attr.xmlns,e);
end
return t:event("stanza",e);
end
function o:reset()
local e=h.new(r(self,i),"\1");
self.parser=e;
self.notopen=true;
return true;
end
function o:connect_client(e,a)
self.jid,self.password=e,a;
self.username,self.host,self.resource=d(e);
self:add_plugin("tls");
self:add_plugin("sasl");
self:add_plugin("bind");
self:add_plugin("session");
function self.data(t,e)
local t,a=self.parser:parse(e);
if t then return;end
o:debug("debug","Received invalid XML (%s) %d bytes: %s",tostring(a),#e,e:sub(1,300):gsub("[\r\n]+"," "));
o:close("xml-not-well-formed");
end
self:hook("incoming-raw",function(e)return self.data(self.conn,e);end);
self.curr_id=0;
self.tracked_iqs={};
self:hook("stanza",function(t)
local e,a=t.attr.id,t.attr.type;
if e and t.name=="iq"and(a=="result"or a=="error")and self.tracked_iqs[e]then
self.tracked_iqs[e](t);
self.tracked_iqs[e]=nil;
return true;
end
end);
self:hook("stanza",function(e)
if e.attr.xmlns==nil or e.attr.xmlns=="jabber:client"then
if e.name=="iq"and(e.attr.type=="get"or e.attr.type=="set")then
local a=e.tags[1]and e.tags[1].attr.xmlns;
if a then
ret=self:event("iq/"..a,e);
if not ret then
ret=self:event("iq",e);
end
end
if ret==nil then
self:send(t.error_reply(e,"cancel","service-unavailable"));
return true;
end
else
ret=self:event(e.name,e);
end
end
return ret;
end,-1);
local function e()
self:event("ready");
end
self:hook("session-success",e,-1)
self:hook("bind-success",e,-1);
local e=self.close;
function self:close(t)
if not self.notopen then
self:send("</stream:stream>");
end
return e(self);
end
local function t()
self:connect(self.connect_host or self.host,self.connect_port or 5222);
self:reopen();
end
if not(self.connect_host or self.connect_port)then
l.lookup(function(a)
if a then
local e={};
self.srv_hosts=e;
for a,t in ipairs(a)do
table.insert(e,t.srv);
end
table.sort(e,s);
local a=e[1];
self.srv_choice=1;
if a then
self.connect_host,self.connect_port=a.target,a.port;
self:debug("Best record found, will connect to %s:%d",self.connect_host or self.host,self.connect_port or 5222);
end
self:hook("disconnected",function()
if self.srv_hosts and self.srv_choice<#self.srv_hosts then
self.srv_choice=self.srv_choice+1;
local e=e[self.srv_choice];
self.connect_host,self.connect_port=e.target,e.port;
t();
return true;
end
end,1e3);
self:hook("connected",function()
self.srv_hosts=nil;
end,1e3);
end
t();
end,"_xmpp-client._tcp."..(self.host)..".","SRV");
else
t();
end
end
function o:reopen()
self:reset();
self:send(a.stanza("stream:stream",{to=self.host,["xmlns:stream"]='http://etherx.jabber.org/streams',
xmlns="jabber:client",version="1.0"}):top_tag());
end
function o:send_iq(e,a)
local t=self:new_id();
self.tracked_iqs[t]=a;
e.attr.id=t;
self:send(e);
end
function o:new_id()
self.curr_id=self.curr_id+1;
return tostring(self.curr_id);
end
end)
package.preload['verse.component']=(function(...)
local o=require"verse";
local t=o.stream_mt;
local d=require"util.jid".split;
local l=require"lxp";
local a=require"util.stanza";
local r=require"util.sha1".sha1;
o.message,o.presence,o.iq,o.stanza,o.reply,o.error_reply=
a.message,a.presence,a.iq,a.stanza,a.reply,a.error_reply;
local h=require"core.xmlhandlers";
local s="http://etherx.jabber.org/streams";
local i="jabber:component:accept";
local n={
stream_ns=s,
stream_tag="stream",
default_ns=i};
function n.streamopened(e,t)
e.stream_id=t.id;
if not e:event("opened",t)then
e.notopen=nil;
end
return true;
end
function n.streamclosed(e)
return e:event("closed");
end
function n.handlestanza(t,e)
if e.attr.xmlns==s then
return t:event("stream-"..e.name,e);
elseif e.attr.xmlns or e.name=="handshake"then
return t:event("stream/"..(e.attr.xmlns or i),e);
end
return t:event("stanza",e);
end
function t:reset()
local e=l.new(h(self,n),"\1");
self.parser=e;
self.notopen=true;
return true;
end
function t:connect_component(e,n)
self.jid,self.password=e,n;
self.username,self.host,self.resource=d(e);
function self.data(a,e)
local o,a=self.parser:parse(e);
if o then return;end
t:debug("debug","Received invalid XML (%s) %d bytes: %s",tostring(a),#e,e:sub(1,300):gsub("[\r\n]+"," "));
t:close("xml-not-well-formed");
end
self:hook("incoming-raw",function(e)return self.data(self.conn,e);end);
self.curr_id=0;
self.tracked_iqs={};
self:hook("stanza",function(e)
local t,a=e.attr.id,e.attr.type;
if t and e.name=="iq"and(a=="result"or a=="error")and self.tracked_iqs[t]then
self.tracked_iqs[t](e);
self.tracked_iqs[t]=nil;
return true;
end
end);
self:hook("stanza",function(e)
if e.attr.xmlns==nil or e.attr.xmlns=="jabber:client"then
if e.name=="iq"and(e.attr.type=="get"or e.attr.type=="set")then
local t=e.tags[1]and e.tags[1].attr.xmlns;
if t then
ret=self:event("iq/"..t,e);
if not ret then
ret=self:event("iq",e);
end
end
if ret==nil then
self:send(o.error_reply(e,"cancel","service-unavailable"));
return true;
end
else
ret=self:event(e.name,e);
end
end
return ret;
end,-1);
self:hook("opened",function(e)
print(self.jid,self.stream_id,e.id);
local e=r(self.stream_id..n,true);
self:send(a.stanza("handshake",{xmlns=i}):text(e));
self:hook("stream/"..i,function(e)
if e.name=="handshake"then
self:event("authentication-success");
end
end);
end);
local function e()
self:event("ready");
end
self:hook("authentication-success",e,-1);
self:connect(self.connect_host or self.host,self.connect_port or 5347);
self:reopen();
end
function t:reopen()
self:reset();
self:send(a.stanza("stream:stream",{to=self.host,["xmlns:stream"]='http://etherx.jabber.org/streams',
xmlns=i,version="1.0"}):top_tag());
end
function t:close(e)
if not self.notopen then
self:send("</stream:stream>");
end
local t=self.conn.disconnect();
self.conn:close();
t(conn,e);
end
function t:send_iq(e,a)
local t=self:new_id();
self.tracked_iqs[t]=a;
e.attr.id=t;
self:send(e);
end
function t:new_id()
self.curr_id=self.curr_id+1;
return tostring(self.curr_id);
end
end)
pcall(require,"luarocks.require");
pcall(require,"ssl");
local o=require"net.server";
local n=require"util.events";
module("verse",package.seeall);
local e=_M;
local t={};
t.__index=t;
stream_mt=t;
e.plugins={};
function e.new(o,a)
local t=setmetatable(a or{},t);
t.id=tostring(t):match("%x*$");
t:set_logger(o,true);
t.events=n.new();
return t;
end
e.add_task=require"util.timer".add_task;
e.logger=logger.init;
e.log=e.logger("verse");
function e.set_logger(t)
e.log=t;
o.setlogger(t);
end
function e.filter_log(e,o)
local t={};
for a,e in ipairs(e)do
t[e]=true;
end
return function(e,a,...)
if t[e]then
return o(e,a,...);
end
end;
end
local function a(t)
e.log("error","Error: %s",t);
e.log("error","Traceback: %s",debug.traceback());
end
function e.set_error_handler(e)
a=e;
end
function e.loop()
return xpcall(o.loop,a);
end
function e.step()
return xpcall(o.step,a);
end
function e.quit()
return o.setquitting(true);
end
function t:connect(a,t)
a=a or"localhost";
t=tonumber(t)or 5222;
local i=socket.tcp()
i:settimeout(0);
local n,e=i:connect(a,t);
if not n and e~="timeout"then
self:warn("connect() to %s:%d failed: %s",a,t,e);
return self:event("disconnected",{reason=e})or false,e;
end
local t=o.wrapclient(i,a,t,new_listener(self),"*a");
if not t then
self:warn("connection initialisation failed: %s",e);
return self:event("disconnected",{reason=e})or false,e;
end
self.conn=t;
local a,e=t.write,tostring;
self.send=function(i,o)return a(t,e(o));end
return true;
end
function t:close()
if not self.conn then
e.log("error","Attempt to close disconnected connection - possibly a bug");
return;
end
local e=self.conn.disconnect();
self.conn:close();
e(conn,reason);
end
function t:debug(...)
if self.logger and self.log.debug then
return self.logger("debug",...);
end
end
function t:warn(...)
if self.logger and self.log.warn then
return self.logger("warn",...);
end
end
function t:error(...)
if self.logger and self.log.error then
return self.logger("error",...);
end
end
function t:set_logger(t,e)
local a=self.logger;
if t then
self.logger=t;
end
if e then
if e==true then
e={"debug","info","warn","error"};
end
self.log={};
for t,e in ipairs(e)do
self.log[e]=true;
end
end
return a;
end
function stream_mt:set_log_levels(e)
self:set_logger(nil,e);
end
function t:event(e,...)
self:debug("Firing event: "..tostring(e));
return self.events.fire_event(e,...);
end
function t:hook(e,...)
return self.events.add_handler(e,...);
end
function t:unhook(e,t)
return self.events.remove_handler(e,t);
end
function e.eventable(e)
e.events=n.new();
e.hook,e.unhook=t.hook,t.unhook;
local t=e.events.fire_event;
function e:event(e,...)
return t(e,...);
end
return e;
end
function t:add_plugin(t)
if require("verse.plugins."..t)then
local e,a=e.plugins[t](self);
if e then
self:debug("Loaded %s plugin",t);
else
self:warn("Failed to load %s plugin: %s",t,a);
end
end
return self;
end
function new_listener(e)
local t={};
function t.onconnect(a)
e.connected=true;
e.send=function(t,e)t:debug("Sending data: "..tostring(e));return a:write(tostring(e));end;
e:event("connected");
end
function t.onincoming(a,t)
e:event("incoming-raw",t);
end
function t.ondisconnect(a,t)
e.connected=false;
e:event("disconnected",{reason=t});
end
function t.ondrain(t)
e:event("drained");
end
function t.onstatus(a,t)
e:event("status",t);
end
return t;
end
local t=require"util.logger".init("verse");
return e;
