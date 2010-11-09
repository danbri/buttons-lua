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
local i,t=select,tostring;
local n=io.write;
module"logger"
local function e(a,...)
local e,o=0,#arg;
return(a:gsub("%%(.)",function(a)if a~="%"and e<=o then e=e+1;return t(arg[e]);end end));
end
local function a(a,...)
local e,o=0,i('#',...);
local i={...};
return(a:gsub("%%(.)",function(a)if e<=o then e=e+1;return t(i[e]);end end));
end
function init(e)
return function(e,t,...)
n(e,"\t",a(t,...),"\n");
end
end
return _M;
end)
package.preload['util.sha1']=(function(...)
local d=string.len
local a=string.char
local q=string.byte
local j=string.sub
local r=math.floor
local t=require"bit"
local k=t.bnot
local e=t.band
local y=t.bor
local n=t.bxor
local i=t.lshift
local o=t.rshift
local l,u,c,s,m
local function p(t,e)
return i(t,e)+o(t,32-e)
end
local function h(i)
local t,o
local t=""
for n=1,8 do
o=e(i,15)
if(o<10)then
t=a(o+48)..t
else
t=a(o+87)..t
end
i=r(i/16)
end
return t
end
local function g(t)
local i,o
local n=""
i=d(t)*8
t=t..a(128)
o=56-e(d(t),63)
if(o<0)then
o=o+64
end
for e=1,o do
t=t..a(0)
end
for t=1,8 do
n=a(e(i,255))..n
i=r(i/256)
end
return t..n
end
local function b(w)
local r,t,a,o,f,d,h,v
local i,i
local i={}
while(w~="")do
for e=0,15 do
i[e]=0
for t=1,4 do
i[e]=i[e]*256+q(w,e*4+t)
end
end
for e=16,79 do
i[e]=p(n(n(i[e-3],i[e-8]),n(i[e-14],i[e-16])),1)
end
r=l
t=u
a=c
o=s
f=m
for s=0,79 do
if(s<20)then
d=y(e(t,a),e(k(t),o))
h=1518500249
elseif(s<40)then
d=n(n(t,a),o)
h=1859775393
elseif(s<60)then
d=y(y(e(t,a),e(t,o)),e(a,o))
h=2400959708
else
d=n(n(t,a),o)
h=3395469782
end
v=p(r,5)+d+f+h+i[s]
f=o
o=a
a=p(t,30)
t=r
r=v
end
l=e(l+r,4294967295)
u=e(u+t,4294967295)
c=e(c+a,4294967295)
s=e(s+o,4294967295)
m=e(m+f,4294967295)
w=j(w,65)
end
end
local function t(e,t)
e=g(e)
l=1732584193
u=4023233417
c=2562383102
s=271733878
m=3285377520
b(e)
local e=h(l)..h(u)..h(c)
..h(s)..h(m);
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
local n,r=require"util.stanza",require"util.uuid";
local h="http://jabber.org/protocol/commands";
local i={}
local s={};
function _cmdtag(o,e,a,t)
local e=n.stanza("command",{xmlns=h,node=o.node,status=e});
if a then e.attr.sessionid=a;end
if t then e.attr.action=t;end
return e;
end
function s.new(a,e,t,o)
return{name=a,node=e,handler=t,cmdtag=_cmdtag,permission=(o or"user")};
end
function s.handle_cmd(a,s,o)
local e=o.tags[1].attr.sessionid or r.generate();
local t={};
t.to=o.attr.to;
t.from=o.attr.from;
t.action=o.tags[1].attr.action or"execute";
t.form=o.tags[1]:child_with_ns("jabber:x:data");
local t,h=a:handler(t,i[e]);
i[e]=h;
local o=n.reply(o);
if t.status=="completed"then
i[e]=nil;
cmdtag=a:cmdtag("completed",e);
elseif t.status=="canceled"then
i[e]=nil;
cmdtag=a:cmdtag("canceled",e);
elseif t.status=="error"then
i[e]=nil;
o=n.error_reply(o,t.error.type,t.error.condition,t.error.message);
s.send(o);
return true;
else
cmdtag=a:cmdtag("executing",e);
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
for o,e in ipairs(e)do
if(e=="prev")or(e=="next")or(e=="complete")then
t:tag(e):up();
else
module:log("error",'Command "'..a.name..
'" at node "'..a.node..'" provided an invalid action "'..e..'"');
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
o:add_child(cmdtag);
s.send(o);
return true;
end
return s;
end)
package.preload['util.stanza']=(function(...)
local e=table.insert;
local t=table.concat;
local m=table.remove;
local w=table.concat;
local h=string.format;
local y=string.match;
local c=tostring;
local u=setmetatable;
local p=getmetatable;
local s=pairs;
local n=ipairs;
local o=type;
local t=next;
local t=print;
local t=unpack;
local b=string.gsub;
local t=string.char;
local l=string.find;
local t=os;
local d=not t.getenv("WINDIR");
local r,a;
if d then
local t,e=pcall(require,"util.termcolours");
if t then
r,a=e.getstyle,e.getstring;
else
d=nil;
end
end
local f="urn:ietf:params:xml:ns:xmpp-stanzas";
module"stanza"
stanza_mt={__type="stanza"};
stanza_mt.__index=stanza_mt;
function stanza(t,e)
local e={name=t,attr=e or{},tags={},last_add={}};
return u(e,stanza_mt);
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
local n,o=1,#t;
return function()
for o=n,o do
v=t[o];
if(not a or v.name==a)
and(not e or e==v.attr.xmlns)then
n=o+1;
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
local t={["'"]="&apos;",["\""]="&quot;",["<"]="&lt;",[">"]="&gt;",["&"]="&amp;"};
function i(e)return(b(e,"['&<>\"]",t));end
_M.xml_escape=i;
end
local function m(a,t,h,o,d)
local i=0;
local r=a.name
e(t,"<"..r);
for a,n in s(a.attr)do
if l(a,"\1",1,true)then
local a,s=y(a,"^([^\1]*)\1?(.*)$");
i=i+1;
e(t," xmlns:ns"..i.."='"..o(a).."' ".."ns"..i..":"..s.."='"..o(n).."'");
elseif not(a=="xmlns"and n==d)then
e(t," "..a.."='"..o(n).."'");
end
end
local i=#a;
if i==0 then
e(t,"/>");
else
e(t,">");
for i=1,i do
local i=a[i];
if i.name then
h(i,t,h,o,a.attr.xmlns);
else
e(t,o(i));
end
end
e(t,"</"..r..">");
end
end
function stanza_mt.__tostring(t)
local e={};
m(t,e,m,i,nil);
return w(e);
end
function stanza_mt.top_tag(e)
local t="";
if e.attr then
for e,a in s(e.attr)do if o(e)=="string"then t=t..h(" %s='%s'",e,i(c(a)));end end
end
return h("<%s%s>",e.name,t);
end
function stanza_mt.get_text(e)
if#e.tags==0 then
return w(e);
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
if a.attr.xmlns==f then
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
if l(e,"|",1,true)and not l(e,"\1",1,true)then
local t,o=y(e,"^([^|]+)|(.+)$");
i[t.."\1"..o]=a[e];
a[e]=nil;
end
end
for t,e in s(i)do
a[t]=e;
end
u(t,stanza_mt);
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
return u(t,p(e));
end
return a(n)
end
function message(t,e)
if not e then
return stanza("message",t);
else
return stanza("message",t):tag("body"):text(e):up();
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
local a={xmlns=f};
function error_reply(e,o,i,t)
local e=reply(e);
e.attr.type="error";
e:tag("error",{type=o})
:tag(i,a):up();
if(t)then e:tag("text",a):text(t):up();end
return e;
end
end
function presence(e)
return stanza("presence",e);
end
if d then
local d=r("yellow");
local l=r("red");
local t=r("red");
local e=r("magenta");
local r=" "..a(d,"%s")..a(e,"=")..a(l,"'%s'");
local d=a(e,"<")..a(t,"%s").."%s"..a(e,">");
local l=d.."%s"..a(e,"</")..a(t,"%s")..a(e,">");
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
for e,t in s(t.attr)do if o(e)=="string"then a=a..h(r,e,c(t));end end
end
return h(l,t.name,a,e,t.name);
end
function stanza_mt.pretty_top_tag(t)
local e="";
if t.attr then
for t,a in s(t.attr)do if o(t)=="string"then e=e..h(r,t,c(a));end end
end
return h(d,t.name,e);
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
local h=os.time;
local n=table.insert;
local e=table.remove;
local e,s=ipairs,pairs;
local l=type;
local o={};
local e={};
module"timer"
local a;
if not i then
function a(t,o)
local a=h();
t=t+a;
if t>=a then
n(e,{t,o});
else
o();
end
end
r(function()
local t=h();
if#e>0 then
for a,t in s(e)do
n(o,t);
end
e={};
end
for n,e in s(o)do
local i,e=e[1],e[2];
if i<=t then
o[n]=nil;
local t=e(t);
if l(t)=="number"then a(t,e);end
end
end
end);
else
local o=(i.core and i.core.LEAVE)or-1;
function a(a,e)
local t;
t=d:addevent(nil,0,function()
local e=e();
if e then
return 0,e;
elseif t then
return o;
end
end
,a);
end
end
add_task=a;
return _M;
end)
package.preload['util.termcolours']=(function(...)
local o,s=table.concat,table.insert;
local e,h=string.char,string.format;
local n=ipairs;
module"termcolours"
local i={
reset=0;bright=1,dim=2,underscore=4,blink=5,reverse=7,hidden=8;
black=30;red=31;green=32;yellow=33;blue=34;magenta=35;cyan=36;white=37;
["black background"]=40;["red background"]=41;["green background"]=42;["yellow background"]=43;["blue background"]=44;["magenta background"]=45;["cyan background"]=46;["white background"]=47;
bold=1,dark=2,underline=4,underlined=4,normal=0;
}
local a=e(27).."[%sm%s"..e(27).."[0m";
function getstring(t,e)
if t then
return h(a,t,e);
else
return e;
end
end
function getstyle(...)
local e,t={...},{};
for a,e in n(e)do
e=i[e];
if e then
s(t,e);
end
end
return o(t,";");
end
return _M;
end)
package.preload['util.uuid']=(function(...)
local e=math.random;
local n=tostring;
local e=os.time;
local i=os.clock;
local o=require"util.hashes".sha1;
module"uuid"
local t=0;
local function a()
local e=e();
if t>=e then e=t+1;end
t=e;
return e;
end
local function t(e)
return o(e..i()..n({}),true);
end
local e=t(a());
local function o(a)
e=t(e..a);
end
local function t(t)
if#e<t then o(a());end
local a=e:sub(0,t);
e=e:sub(t+1);
return a;
end
local function e()
return("%x"):format(t(1):byte()%4+8);
end
function generate()
return t(8).."-"..t(4).."-4"..t(3).."-"..(e())..t(3).."-"..t(12);
end
seed=o;
return _M;
end)
package.preload['net.dns']=(function(...)
local i=require"socket";
local e=require"util.ztact";
local k=require"util.timer";
local t,v=pcall(require,"util.windows");
local E=(t and v)or os.getenv("WINDIR");
local u,T,y,a,r=
coroutine,io,math,string,table;
local w,h,o,m,s,p,j,q,t=
ipairs,next,pairs,print,setmetatable,tostring,assert,error,unpack;
local d,l=e.get,e.set;
local x=15;
module('dns')
local t=_M;
local n=r.insert
local function c(e)
return(e-(e%256))/256;
end
local function b(e)
local t={};
for o,e in o(e)do
t[o]=e;
t[e]=e;
t[a.lower(e)]=e;
end
return t;
end
local function f(i)
local e={};
for t,i in o(i)do
local o=a.char(c(t),t%256);
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
t.type=b(t.types);
t.class=b(t.classes);
t.typecode=f(t.types);
t.classcode=f(t.classes);
local function g(e,i,o)
if a.byte(e,-1)~=46 then e=e..'.';end
e=a.lower(e);
return e,t.type[i or'A'],t.class[o or'IN'];
end
local function b(a,t,n)
t=t or i.gettime();
for o,e in o(a)do
if e.tod then
e.ttl=y.floor(e.tod-t);
if e.ttl<=0 then
r.remove(a,o);
return b(a,t,n);
end
elseif n=='soft'then
j(e.ttl==0);
a[o]=nil;
end
end
end
local e={};
e.__index=e;
e.timeout=x;
local j;
local x={};
function x.__tostring(t)
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
o=' '..j(t);
elseif t.type=='TXT'then
o=' '..t.txt;
else
o=' <UNKNOWN RDATA TYPE>';
end
return i..o;
end
local z={};
function z.__tostring(t)
local e={};
for a,t in o(t)do
n(e,p(t)..'\n');
end
return r.concat(e);
end
local f={};
function f.__tostring(e)
local a=i.gettime();
local t={};
for i,e in o(e)do
for i,e in o(e)do
for o,e in o(e)do
b(e,a);
n(t,p(e));
end
end
end
return r.concat(t);
end
function e:new()
local t={active={},cache={},unsorted={}};
s(t,e);
s(t.cache,f);
s(t.unsorted,{__mode='kv'});
return t;
end
function t.random(...)
y.randomseed(y.floor(1e4*i.gettime()));
t.random=y.random;
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
c(e.id),e.id%256,
e.rd+2*e.tc+4*e.aa+8*e.opcode+128*e.qr,
e.rcode+16*e.z+128*e.ra,
c(e.qdcount),e.qdcount%256,
c(e.ancount),e.ancount%256,
c(e.nscount),e.nscount%256,
c(e.arcount),e.arcount%256
);
return t,e.id;
end
local function c(t)
local e={};
for t in a.gmatch(t,'[^.]+')do
n(e,a.char(a.len(t)));
n(e,t);
end
n(e,a.char(0));
return r.concat(e);
end
local function y(e,o,a)
e=c(e);
o=t.typecode[o or'a'];
a=t.classcode[a or'in'];
return e..o..a;
end
function e:byte(e)
e=e or 1;
local t=self.offset;
local o=t+e-1;
if o>#self.packet then
q(a.format('out of bounds: %i>%i',o,#self.packet));
end
self.offset=t+e;
return a.byte(self.packet,t,o);
end
function e:word()
local e,t=self:byte(2);
return 256*e+t;
end
function e:dword()
local t,a,o,e=self:byte(4);
return 16777216*t+65536*a+256*o+e;
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
if t>=20 then q('dns error: 20 pointers');end;
local e=((e-192)*256)+self:byte();
a=a or self.offset;
self.offset=e+1;
else
n(o,self:sub(e)..'.');
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
function e:A(t)
local e,o,i,n=self:byte(4);
t.a=a.format('%i.%i.%i.%i',e,o,i,n);
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
local function c(e,i,t)
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
n(t,a.format(
'%s    %s    %.2fm %.2fm %.2fm %.2fm',
c(e.loc.latitude,'N','S'),
c(e.loc.longitude,'E','W'),
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
function j(e)
local e=e.srv;
return a.format('%5d %5d %5d %s',e.priority,e.weight,e.port,e.target);
end
function e:TXT(e)
e.txt=self:sub(e.rdlength);
end
function e:rr()
local e={};
s(e,x);
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
for t=1,t do n(e,self:rr());end
return e;
end
function e:decode(t,o)
self.packet,self.offset=t,1;
local t=self:header(o);
if not t then return nil;end
local t={header=t};
t.question={};
local i=self.offset;
for e=1,t.header.qdcount do
n(t.question,self:question());
end
t.question.raw=a.sub(self.packet,i,self.offset-1);
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
n(self.server,e);
end
function e:setnameserver(e)
self.server={};
self:addnameserver(e);
end
function e:adddefaultnameservers()
if E then
if v and v.get_nameservers then
for t,e in w(v.get_nameservers())do
self:addnameserver(e);
end
end
if not self.server or#self.server==0 then
self:addnameserver("208.67.222.222");
self:addnameserver("208.67.220.220");
end
else
local e=T.open("/etc/resolv.conf");
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
e=i.udp();
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
for t,e in w(self.socket)do
self.socket[t]=nil;
self.socketset[e]=nil;
e:close();
end
end
function e:remember(t,e)
local a,i,o=g(t.name,t.type,t.class);
if e~='*'then
e=i;
local e=d(self.cache,o,'*',a);
if e then n(e,t);end
end
self.cache=self.cache or s({},f);
local a=d(self.cache,o,e,a)or
l(self.cache,o,e,a,s({},z));
n(a,t);
if e=='MX'then self.unsorted[a]=true;end
end
local function n(e,t)
return(e.pref==t.pref)and(e.mx<t.mx)or(e.pref<t.pref);
end
function e:peek(a,t,o)
a,t,o=g(a,t,o);
local e=d(self.cache,o,t,a);
if not e then return nil;end
if b(e,i.gettime())and t=='*'or not h(e)then
l(self.cache,o,t,a,nil);
return nil;
end
if self.unsorted[e]then r.sort(e,n);end
return e;
end
function e:purge(e)
if e=='soft'then
self.time=i.gettime();
for t,e in o(self.cache or{})do
for t,e in o(e)do
for t,e in o(e)do
b(e,self.time,'soft')
end
end
end
else self.cache={};end
end
function e:query(a,t,e)
a,t,e=g(a,t,e)
if not self.server then self:adddefaultnameservers();end
local s=y(a,t,e);
local o=self:peek(a,t,e);
if o then return o;end
local o,n=_();
local o={
packet=o..s,
server=self.best_server,
delay=1,
retry=i.gettime()+self.delays[1]
};
self.active[n]=self.active[n]or{};
self.active[n][s]=o;
local n=u.running();
if n then
l(self.wanted,e,t,a,n,true);
end
local i=self:getsocket(o.server)
i:send(o.packet)
if k and self.timeout then
local h=#self.server;
local s=1;
k.add_task(self.timeout,function()
if d(self.wanted,e,t,a,n)then
if s<h then
s=s+1;
self:servfail(i);
o.server=self.best_server;
i=self:getsocket(o.server);
i:send(o.packet);
return self.timeout;
else
self:cancel(e,t,a,n,true);
end
end
end)
end
end
function e:servfail(e)
local t=self.socketset[e]
self:voidsocket(e);
self.time=i.gettime();
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
self.time=i.gettime();
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
if u.status(t)=="suspended"then u.resume(t);end
end
l(self.wanted,e.class,e.type,e.name,nil);
end
end
end
end
end
return e;
end
function e:feed(a,e,t)
self.time=i.gettime();
local e=self:decode(e,t);
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
if u.status(t)=="suspended"then u.resume(t);end
end
l(self.wanted,e.class,e.type,e.name,nil);
end
end
end
return e;
end
function e:cancel(a,i,t,e,o)
local t=d(self.wanted,a,i,t);
if t then
if o then
u.resume(e);
end
t[e]=nil;
end
end
function e:pulse()
while self:receive()do end
if not h(self.active)then return nil;end
self.time=i.gettime();
for i,t in o(self.active)do
for a,e in o(t)do
if self.time>=e.retry then
e.server=e.server+1;
if e.server>#self.server then
e.server=1;
e.delay=e.delay+1;
end
if e.delay>#self.delays then
t[a]=nil;
if not h(t)then self.active[i]=nil;end
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
function e:lookup(a,t,e)
self:query(a,t,e)
while self:pulse()do
local e={}
for t,a in w(self.socket)do
e[t]=a
end
i.select(e,nil,4)
end
return self:peek(a,t,e);
end
function e:lookupex(o,e,t,a)
return self:peek(e,t,a)or self:query(e,t,a);
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
local function h(t,e)
return(i[e]and i[e][t[e]])or'';
end
function e.print(t)
for o,e in o{'id','qr','opcode','aa','tc','rd','ra','z',
'rcode','qdcount','ancount','nscount','arcount'}do
m(a.format('%-30s','header.'..e),t.header[e],h(t.header,e));
end
for e,t in w(t.question)do
m(a.format('question[%i].name         ',e),t.name);
m(a.format('question[%i].type         ',e),t.type);
m(a.format('question[%i].class        ',e),t.class);
end
local s={name=1,type=1,class=1,ttl=1,rdlength=1,rdata=1};
local e;
for n,i in o({'answer','authority','additional'})do
for n,t in o(t[i])do
for s,o in o({'name','type','class','ttl','rdlength'})do
e=a.format('%s[%i].%s',i,n,o);
m(a.format('%-30s',e),t[o],h(t,o));
end
for t,o in o(t)do
if not s[t]then
e=a.format('%s[%i].%s',i,n,t);
m(a.format('%-30s  %s',p(e),p(o)));
end
end
end
end
end
function t.resolver()
local t={active={},cache={},unsorted={},wanted={},yielded={},best_server=1};
s(t,e);
s(t.cache,f);
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
local o,s,l=coroutine,tostring,pcall;
local function d(a,a,t,e)return(e-t)+1;end
module"adns"
function lookup(r,e,n,i)
return o.wrap(function(h)
if h then
t("debug","Records for %s already cached, using those...",e);
r(h);
return;
end
t("debug","Records for %s not in cache, sending query (%s)...",e,s(o.running()));
a.query(e,n,i);
o.yield({i or"IN",n or"A",e,o.running()});
t("debug","Reply for %s (%s)",e,s(o.running()));
local e,a=l(r,a.peek(e,n,i));
if not e then
t("error","Error in DNS response handler: %s",s(a));
end
end)(a.peek(e,n,i));
end
function cancel(e,o,i)
t("warn","Cancelling DNS lookup for %s",s(e[3]));
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
function n.ondisconnect(a,i)
if i then
t("warn","DNS socket for %s disconnected: %s",s,i);
local e=o.server;
if o.socketset[a]==o.best_server and o.best_server==#e then
t("error","Exhausted all %d configured DNS servers, next lookup will try %s again",#e,e[1]);
end
o:servfail(a);
end
end
e=u.wrapclient(i,"dns",53,n);
if not e then
t("warn","handler is nil");
end
e.settimeout=function()end
e.setsockname=function(t,...)return i:setsockname(...);end
e.setpeername=function(t,...)s=(...);local a=i:setpeername(...);t:set_send(d);return a;end
e.connect=function(t,...)return i:connect(...)end
e.send=function(t,e)return i:send(e);end
return e;
end
a.socket_wrapper_set(new_async_socket);
return _M;
end)
package.preload['net.server']=(function(...)
local d=function(e)
return _G[e]
end
local J=function(e)
for t,a in pairs(e)do
e[t]=nil
end
end
local I,e=require("util.logger").init("socket"),table.concat;
local i=function(...)return I("debug",e{...});end
local X=function(...)return I("warn",e{...});end
local e=collectgarbage
local ee=1
local N=d"type"
local A=d"pairs"
local Z=d"ipairs"
local s=d"tostring"
local e=d"collectgarbage"
local o=d"os"
local a=d"table"
local t=d"string"
local e=d"coroutine"
local V=o.time
local S=o.difftime
local G=a.concat
local a=a.remove
local K=t.len
local me=t.sub
local fe=e.wrap
local ce=e.yield
local b=d"ssl"
local O=d"socket"or require"socket"
local Q=(b and b.wrap)
local ue=O.bind
local de=O.sleep
local le=O.select
local e=(b and b.newcontext)
local B
local F
local ae
local M
local W
local te
local se
local ne
local oe
local ie
local P
local l
local he
local e
local L
local re
local y
local h
local U
local r
local n
local z
local p
local f
local c
local a
local o
local v
local D
local R
local x
local T
local C
local u
local _
local E
local j
local q
local k
local H
local Y
local g
y={}
h={}
r={}
U={}
n={}
p={}
f={}
z={}
a=0
o=0
v=0
D=0
R=0
x=1
T=0
_=51e3*1024
E=25e3*1024
j=12e5
q=6e4
k=6*60*60
H=false
g=1e3
_maxsslhandshake=30
oe=function(c,t,v,u,p,m,f)
f=f or g
local d=0
local w,e=c.onconnect or c.onincoming,c.ondisconnect
local y=t.accept
local e={}
e.shutdown=function()end
e.ssl=function()
return m~=nil
end
e.sslctx=function()
return m
end
e.remove=function()
d=d-1
end
e.close=function()
for a,e in A(n)do
if e.serverport==u then
e.disconnect(e,"server closed")
e:close(true)
end
end
t:close()
o=l(r,t,o)
a=l(h,t,a)
n[t]=nil
e=nil
t=nil
i"server.lua: closed server handler and removed sockets from list"
end
e.ip=function()
return v
end
e.serverport=function()
return u
end
e.socket=function()
return t
end
e.readbuffer=function()
if d>f then
i("server.lua: refused new client connection: server full")
return false
end
local t,n=y(t)
if t then
local o,a=t:getpeername()
t:settimeout(0)
local e,n,t=L(e,c,t,o,u,a,p,m)
if t then
return false
end
d=d+1
i("server.lua: accepted new client connection from ",s(o),":",s(a)," to ",s(u))
return w(e)
elseif n then
i("server.lua: error with new client connection: ",s(n))
return false
end
end
return e
end
L=function(X,e,t,P,Z,Y,T,g)
t:settimeout(0)
local w
local A
local k
local O
local S=e.onincoming
local L=e.onstatus
local v=e.ondisconnect
local W=e.ondrain
local y={}
local m=0
local V
local F
local C
local d=0
local q=false
local I=false
local U,N=0,0
local x=_
local j=E
local e=y
e.dispatch=function()
return S
end
e.disconnect=function()
return v
end
e.setlistener=function(a,t)
S=t.onincoming
v=t.ondisconnect
L=t.onstatus
W=t.ondrain
end
e.getstats=function()
return N,U
end
e.ssl=function()
return O
end
e.sslctx=function()
return g
end
e.send=function(n,o,i,a)
return w(t,o,i,a)
end
e.receive=function(o,a)
return A(t,o,a)
end
e.shutdown=function(a)
return k(t,a)
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
if m~=0 then
if not(s or F)then
e.sendbuffer()
if m~=0 then
if e then
e.write=nil
end
V=true
return false
end
else
w(t,G(y,"",1,m),1,d)
end
end
if t then
c=k and k(t)
t:close()
o=l(r,t,o)
n[t]=nil
t=nil
else
i"server.lua: socket already closed"
end
if e then
f[e]=nil
z[e]=nil
e=nil
end
if X then
X.remove()
end
i"server.lua: closed client handler and removed socket from list"
return true
end
e.ip=function()
return P
end
e.serverport=function()
return Z
end
e.clientport=function()
return Y
end
local z=function(i,a)
d=d+K(a)
if d>x then
z[e]="send buffer exceeded"
e.write=M
return false
elseif t and not r[t]then
o=addsocket(r,t,o)
end
m=m+1
y[m]=a
if e then
f[e]=f[e]or u
end
return true
end
e.write=z
e.bufferqueue=function(t)
return y
end
e.socket=function(a)
return t
end
e.set_mode=function(a,t)
T=t or T
return T
end
e.set_send=function(a,t)
w=t or w
return w
end
e.bufferlen=function(o,a,t)
x=t or x
j=a or j
return d,j,x
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
e.write=M
local a=o
o=l(r,t,o)
f[e]=nil
if o~=a then
I=true
end
elseif a==false then
e.write=z
if I then
I=false
z("")
end
end
return q,I
end
local q=function()
local a,t,o=A(t,T)
if not t or(t=="wantread"or t=="timeout")then
local a=a or o or""
local o=K(a)
if o>j then
v(e,"receive buffer exceeded")
e:close(true)
return false
end
local o=o*ee
N=N+o
R=R+o
p[e]=u
return S(e,a,t)
else
i("server.lua: client ",s(P),":",s(Y)," read error: ",s(t))
F=true
v(e,t)
c=e and e:close()
return false
end
end
local f=function()
local p,a,n,h,b;
local b;
if t then
h=G(y,"",1,m)
p,a,n=w(t,h,1,d)
b=(p or n or 0)*ee
U=U+b
D=D+b
c=H and J(y)
else
p,a,b=false,"closed",0;
end
if p then
m=0
d=0
o=l(r,t,o)
f[e]=nil
if W then
W(e)
end
c=C and e:starttls(nil)
c=V and e:close()
return true
elseif n and(a=="timeout"or a=="wantwrite")then
h=me(h,n+1,d)
y[1]=h
m=1
d=d-n
f[e]=u
return true
else
i("server.lua: client ",s(P),":",s(Y)," write error: ",s(a))
F=true
v(e,a)
c=e and e:close()
return false
end
end
local d;
function e.set_sslctx(n,t)
O=true
g=t;
local m
local u
d=fe(function(t)
local n
for d=1,_maxsslhandshake do
o=(m and l(r,t,o))or o
a=(u and l(h,t,a))or a
u,m=nil,nil
c,n=t:dohandshake()
if not n then
i("server.lua: ssl handshake done")
e.readbuffer=q
e.sendbuffer=f
c=L and L(e,"ssl-handshake-complete")
a=addsocket(h,t,a)
return true
else
i("server.lua: error during ssl handshake: ",s(n))
if n=="wantwrite"and not m then
o=addsocket(r,t,o)
m=true
elseif n=="wantread"and not u then
a=addsocket(h,t,a)
u=true
else
break;
end
ce()
end
end
v(e,"ssl handshake failed")
c=e and e:close(true)
return false
end
)
end
if b then
if g then
e:set_sslctx(g);
i("server.lua: ","starting ssl handshake")
local a
t,a=Q(t,g)
if a then
i("server.lua: ssl error: ",s(a))
return nil,nil,a
end
t:settimeout(0)
e.readbuffer=d
e.sendbuffer=d
d(t)
if not t then
return nil,nil,"ssl handshake failed";
end
else
local c;
e.starttls=function(f,u)
if u then
c=u;
e:set_sslctx(c);
end
if m>0 then
i"server.lua: we need to do tls, but delaying until send buffer empty"
C=true
return
end
i("server.lua: attempting to start tls on "..s(t))
local m,u=t
t,u=Q(t,c)
if u then
i("server.lua: error while starting tls on client: ",s(u))
return nil,u
end
t:settimeout(0)
w=t.send
A=t.receive
k=B
n[t]=e
a=addsocket(h,t,a)
a=l(h,m,a)
o=l(r,m,o)
n[m]=nil
e.starttls=nil
C=nil
O=true
e.readbuffer=d
e.sendbuffer=d
d(t)
end
e.readbuffer=q
e.sendbuffer=f
end
else
e.readbuffer=q
e.sendbuffer=f
end
w=t.send
A=t.receive
k=(O and B)or t.shutdown
n[t]=e
a=addsocket(h,t,a)
return e,t
end
B=function()
end
M=function()
return false
end
addsocket=function(a,t,e)
if not a[t]then
e=e+1
a[e]=t
a[t]=e
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
P=function(e)
o=l(r,e,o)
a=l(h,e,a)
n[e]=nil
e:close()
end
local function m(a,e,o)
local t;
local i=e.sendbuffer;
function e.sendbuffer()
i();
if t and e.bufferlen()<o then
a:lock_read(false);
t=nil;
end
end
local i=a.readbuffer;
function a.readbuffer()
i();
if not t and e.bufferlen()>=o then
t=true;
a:lock_read(true);
end
end
end
se=function(o,e,d,l,r)
local t
if N(d)~="table"then
t="invalid listener table"
end
if N(e)~="number"or not(e>=0 and e<=65535)then
t="invalid port"
elseif y[e]then
t="listeners on port '"..e.."' already exist"
elseif r and not b then
t="luasec not found"
end
if t then
X("server.lua, port ",e,": ",t)
return nil,t
end
o=o or"*"
local t,s=ue(o,e)
if s then
X("server.lua, port ",e,": ",s)
return nil,s
end
local s,d=oe(d,t,o,e,l,r,g)
if not s then
t:close()
return nil,d
end
t:settimeout(0)
a=addsocket(h,t,a)
y[e]=s
n[t]=s
i("server.lua: new "..(r and"ssl "or"").."server listener on '",o,":",e,"'")
return s
end
ne=function(e)
return y[e];
end
he=function(e)
local t=y[e]
if not t then
return nil,"no server found on port '"..s(e).."'"
end
t:close()
y[e]=nil
return true
end
te=function()
for t,e in A(n)do
e:close()
n[t]=nil
end
a=0
o=0
v=0
y={}
h={}
r={}
U={}
n={}
end
ie=function()
return x,T,_,E,j,q,k,H,g,_maxsslhandshake
end
re=function(e)
if N(e)~="table"then
return nil,"invalid settings table"
end
x=tonumber(e.timeout)or x
T=tonumber(e.sleeptime)or T
_=tonumber(e.maxsendlen)or _
E=tonumber(e.maxreadlen)or E
j=tonumber(e.checkinterval)or j
q=tonumber(e.sendtimeout)or q
k=tonumber(e.readtimeout)or k
H=e.cleanqueue
g=e._maxclientsperserver or g
_maxsslhandshake=e._maxsslhandshake or _maxsslhandshake
return true
end
W=function(e)
if N(e)~="function"then
return nil,"invalid listener function"
end
v=v+1
U[v]=e
return true
end
ae=function()
return R,D,a,o,v
end
local e;
setquitting=function(t)
e=not not t;
end
F=function(a)
if e then return"quitting";end
if a then e="once";end
repeat
local a,t,o=le(h,r,x)
for e,t in Z(t)do
local e=n[t]
if e then
e.sendbuffer()
else
P(t)
i"server.lua: found no handler and closed socket (writelist)"
end
end
for e,t in Z(a)do
local e=n[t]
if e then
e.readbuffer()
else
P(t)
i"server.lua: found no handler and closed socket (readlist)"
end
end
for e,t in A(z)do
e.disconnect()(e,t)
e:close(true)
end
J(z)
u=V()
if S(u-Y)>=1 then
for e=1,v do
U[e](u)
end
Y=u
end
de(T)
until e;
if a and e=="once"then e=nil;return;end
return"quitting"
end
step=function()
return F(true);
end
local function h()
return"select";
end
local s=function(t,e,i,a,s,h)
local e=L(nil,a,t,e,i,"clientport",s,h)
n[t]=e
o=addsocket(r,t,o)
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
local a=function(a,o,i,n,h)
local t,e=O.tcp()
if e then
return nil,e
end
t:settimeout(0)
c,e=t:connect(a,o)
if e then
local e=s(t,a,o,i)
else
L(nil,i,t,a,o,"clientport",n,h)
end
end
d"setmetatable"(n,{__mode="k"})
d"setmetatable"(p,{__mode="k"})
d"setmetatable"(f,{__mode="k"})
Y=V()
C=V()
W(function()
local e=S(u-C)
if e>j then
C=u
for e,t in A(f)do
if S(u-t)>q then
e.disconnect()(e,"send timeout")
e:close(true)
end
end
for e,t in A(p)do
if S(u-t)>k then
e.disconnect()(e,"read timeout")
e:close()
end
end
end
end
)
local function t(e)
local t=I;
if e then
I=e;
end
return t;
end
return{
addclient=a,
wrapclient=s,
loop=F,
link=m,
stats=ae,
closeall=te,
addtimer=W,
addserver=se,
getserver=ne,
setlogger=t,
getsettings=ie,
setquitting=setquitting,
removeserver=he,
get_backend=h,
changesettings=re,
}
end)
package.preload['core.xmlhandlers']=(function(...)
require"util.stanza"
local m=stanza;
local i=tostring;
local f=table.insert;
local u=table.concat;
local n=require"util.logger".init("xmlhandlers");
local r=error;
module"xmlhandlers"
local p={
["http://www.w3.org/XML/1998/namespace"]="xml";
};
local l="http://etherx.jabber.org/streams";
local t="\1";
local h="^([^"..t.."]*)"..t.."?(.*)$";
function init_xmlhandlers(a,e)
local o={};
local s={};
local n=a.log or n;
local c=e.streamopened;
local d=e.streamclosed;
local n=e.error or function(t,e)r("XML stream error: "..i(e));end;
local y=e.handlestanza;
local i=e.stream_ns or l;
local l=i..t..(e.stream_tag or"stream");
local w=i..t..(e.error_tag or"error");
local r=e.default_ns;
local e;
function s:StartElement(s,t)
if e and#o>0 then
e:text(u(o));
o={};
end
local i,o=s:match(h);
if o==""then
i,o="",i;
end
if i~=r then
t.xmlns=i;
end
for e=1,#t do
local a=t[e];
t[e]=nil;
local e,o=a:match(h);
if o~=""then
e=p[e];
if e then
t[e..":"..o]=t[a];
t[a]=nil;
end
end
end
if not e then
if a.notopen then
if s==l then
if c then
c(a,t);
end
else
n(a,"no-stream");
end
return;
end
if i=="jabber:client"and o~="iq"and o~="presence"and o~="message"then
n(a,"invalid-top-level-element");
end
e=m.stanza(o,t);
else
t.xmlns=nil;
if i~=r then
t.xmlns=i;
end
e:tag(o,t);
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
e:text(u(o));
o={};
end
if#e.last_add==0 then
if t~=w then
y(a,e);
else
n(a,"stream-error",e);
end
e=nil;
else
e:up();
end
else
if t==l then
if d then
d(a);
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
local function t(e)
if not e then return;end
local o,t=a(e,"^([^@/]+)@()");
local t,i=a(e,"^([^@/]+)()",t)
if o and not t then return nil,nil,nil;end
local a=a(e,"^/(.+)$",i);
if(not t)or((not a)and#e>=i)then return nil,nil,nil;end
return o,t,a;
end
split=t;
function bare(e)
local t,e=t(e);
if t and e then
return t.."@"..e;
end
return e;
end
local function o(e)
local e,t,a=t(e);
if t then
t=n(t);
if not t then return;end
if e then
e=s(e);
if not e then return;end
end
if a then
a=h(a);
if not a then return;end
end
return e,t,a;
end
end
prepped_split=o;
function prep(e)
local t,e,a=o(e);
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
function compare(a,e)
local o,i,n=t(a);
local a,t,e=t(e);
if((a~=nil and a==o)or a==nil)and
((t~=nil and t==i)or t==nil)and
((e~=nil and e==n)or e==nil)then
return true
end
return false
end
return _M;
end)
package.preload['util.events']=(function(...)
local i=pairs;
local h=table.insert;
local r=table.sort;
local s=setmetatable;
local n=next;
module"events"
function new()
local e={};
local t={};
local function o(o,a)
local e=t[a];
if not e or n(e)==nil then return;end
local t={};
for e in i(e)do
h(t,e);
end
r(t,function(t,a)return e[t]>e[a];end);
o[a]=t;
return t;
end;
s(e,{__index=o});
local function n(o,i,n)
local a=t[o];
if a then
a[i]=n or 0;
else
a={[i]=n or 0};
t[o]=a;
end
e[o]=nil;
end;
local function a(a,o)
local t=t[a];
if t then
t[o]=nil;
e[a]=nil;
end
end;
local function o(e)
for e,t in i(e)do
n(e,t);
end
end;
local function s(e)
for t,e in i(e)do
a(t,e);
end
end;
local function i(t,...)
local e=e[t];
if e then
for t=1,#e do
local e=e[t](...);
if e~=nil then return e;end
end
end
end;
return{
add_handler=n;
remove_handler=a;
add_handlers=o;
remove_handlers=s;
fire_event=i;
_handlers=e;
_event_map=t;
};
end
return _M;
end)
package.preload['util.dataforms']=(function(...)
local o=setmetatable;
local e,i=pairs,ipairs;
local s,n=tostring,type;
local r=table.concat;
local d=require"util.stanza";
module"dataforms"
local a='jabber:x:data';
local h={};
local e={__index=h};
function new(t)
return o(t,e);
end
function h.form(t,h,e)
local e=d.stanza("x",{xmlns=a,type=e or"form"});
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
local o={};
for t in t:childtags()do
local a;
for o,e in i(n)do
if e.name==t.attr.var then
a=e.type;
break;
end
end
local e=e[a];
if e then
o[t.attr.var]=e(t);
end
end
return o;
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
local a,w,r,d,h,y,i,c,s=
getfenv,ipairs,next,pairs,pcall,require,select,tostring,type
local f,b=
unpack,xpcall
local e,t,g,o,n,u=io,lfs,os,string,table,pozix
local v,p=assert,print
local l=error
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
a().pcall=h
local l,a,t,h
local function m()
local e=a
a=nil
return h(f(e,1,l))
end
function seterrorhandler(e)
t=e
end
function pcall2(e,...)
h=e
l=i('#',...)
a={...}
if not t then
local e=y('debug')
t=e.traceback
end
return b(m,t)
end
function append(t,...)
local e=n.insert
for o,a in w{...}do
e(t,a)
end end
function print_r(t,a)
local o=o.rep('  ',a or 0)
if s(t)=='table'then
for i,t in d(t)do
if s(t)=='table'then
e.write(o,i,'\n')
print_r(t,(a or 0)+1)
else e.write(o,i,' = ',c(t),'\n')end
end
else e.write(t,'\n')end
end
function tohex(e)
return o.format(o.rep('%02x ',#e),o.byte(e,1,#e))
end
function tostring_r(t,i,h)
local e=h or{}
local o=o.rep('  ',i or 0)
if s(t)=='table'then
for a,t in d(t)do
if s(t)=='table'then
append(e,o,a,'\n')
tostring_r(t,(i or 0)+1,e)
else append(e,o,a,' = ',c(t),'\n')end
end
else append(e,t,'\n')end
if not h then return n.concat(e)end
end
local function h(t,...)
for a=1,10 do e.write((t[a]or'.')..' ')end
e.write('\t')
for a=1,6 do e.write((t.p[a]or'.')..' ')end
p(...)
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
h(t,'  de '..a)
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
h(t,'     '..a)
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
local e=i('#',...)
local s,o=i(e-1,...)
local t,n
for e=1,e-2 do
local i=i(e,...)
local e=a[i]
if o==nil then
if e==nil then return
elseif r(e,r(e))then t=nil n=nil
elseif t==nil then t=a n=i end
elseif e==nil then e={}a[i]=e end
a=e
end
if o==nil and t then t[n]=nil
else a[s]=o return o end
end
function get(e,...)
local t=i('#',...)
for t=1,t do
e=e[i(t,...)]
if e==nil then break end
end
return e
end
function find(e,...)
local t,a={e},{...}
for t in ivalues(a)do
if not t(e)then break end end
while r(t)do
local o=n.remove(t)
for e in v(u.opendir(o))do
if e and e~='.'and e~='..'then
local e=o..'/'..e
if u.stat(e,'is_dir')then n.insert(t,e)end
for t in ivalues(a)do
if not t(e)then break end end
end end end end
function ivalues(t)
local e=0
return function()if t[e+1]then e=e+1 return t[e]end end
end
function lson_encode(i,e,t,a)
local h
if not e then
h={}
e=function(e)append(h,e)end
end
t=t or 0
a=a or{}
a[t]=a[t]or o.rep(' ',2*t)
local s=s(i)
if s=='number'then e(i)
else if s=='string'then e(o.format('%q',i))
else if s=='table'then
e('{')
for i,o in d(i)do
e('\n')
e(a[t])
e('[')e(lson_encode(i))e('] = ')
lson_encode(o,e,t+1,a)
e(',')
end
e(' }')
end end end
if h then return n.concat(h)end
end
function timestamp(e)
return g.date('%Y%m%d.%H%M%S',e)
end
function values(a)
local e,t
return function()e,t=r(a,e)return t end
end
end)
package.preload['verse.plugins.tls']=(function(...)
local a=require"util.stanza";
local t="urn:ietf:params:xml:ns:xmpp-tls";
function verse.plugins.tls(e)
local function o(o)
if e.authenticated then return;end
if o:get_child("starttls",t)and e.conn.starttls then
e:debug("Negotiating TLS...");
e:send(a.stanza("starttls",{xmlns=t}));
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
local function i(t)
if t=="ssl-handshake-complete"then
e.secure=true;
e:debug("Re-opening stream...");
e:reopen();
end
end
e:hook("stream-features",o,400);
e:hook("stream/"..t,a);
e:hook("status",i,400);
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
local function i(o)
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
local o,a,t=t:get_error();
e:event("bind-failure",{error=a,text=t,type=o});
end
end);
end
e:hook("stream-features",i,200);
return true;
end
end)
package.preload['verse.plugins.version']=(function(...)
local a="jabber:iq:version";
local function o(e,t)
e.name=t.name;
e.version=t.version;
e.platform=t.platform;
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
function(e)
local a=e:get_child("query",a);
if e.attr.type=="result"then
local o=a:get_child("name");
local e=a:get_child("version");
local a=a:get_child("os");
t({
name=o and o:get_text()or nil;
version=e and e:get_text()or nil;
platform=a and a:get_text()or nil;
});
else
local a,o,e=e:get_error();
t({
error=true;
condition=o;
text=e;
type=a;
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
local i=socket.gettime();
e:send_iq(verse.iq{to=t,type="get"}:tag("ping",{xmlns=o}),
function(e)
if e.attr.type=="error"then
local i,e,o=e:get_error();
if e~="service-unavailable"and e~="feature-not-implemented"then
a(nil,t,{type=i,condition=e,text=o});
return;
end
end
a(socket.gettime()-i,t);
end);
end
return true;
end
end)
package.preload['verse.plugins.session']=(function(...)
local o=require"util.stanza";
local t="urn:ietf:params:xml:ns:xmpp-session";
function verse.plugins.session(e)
local function i(a)
local a=a:get_child("session",t);
if a and not a:get_child("optional")then
local function a(a)
e:debug("Establishing Session...");
e:send_iq(o.iq({type="set"}):tag("session",{xmlns=t}),
function(t)
if t.attr.type=="result"then
e:event("session-success");
elseif t.attr.type=="error"then
local a=t:child_with_name("error");
local t,a,o=t:get_error();
e:event("session-failure",{error=a,text=o,type=t});
end
end);
return true;
end
e:hook("bind-success",a);
end
end
e:hook("stream-features",i);
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
local function n(e)
local i,o=pcall(i.inflate);
if i==false then
local t=t.stanza("failure",{xmlns=a}):tag("setup-failed");
e:send(t);
e:error("Failed to create zlib.inflate filter: %s",tostring(o));
return
end
return o
end
local function i(e,o)
function e:send(a)
local o,a,i=pcall(o,tostring(a),'sync');
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
local i=e.data
e.data=function(n,a)
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
return i(n,a);
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
local function o(t)
if t.name=="compressed"then
e:debug("Activating compression...")
local t=s(e);
if not t then return end
local a=n(e);
if not a then return end
i(e,t);
r(e,a);
e.compressed=true;
e:reopen();
elseif t.name=="failure"then
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
local r=require"util.uuid";
local h=require"util.sha1";
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
bytestream_sid=r.generate();
});
local a=verse.iq{type="set",to=t}
:tag("query",{xmlns=o,mode="tcp",sid=e.bytestream_sid});
for t,e in ipairs(s or self.proxies)do
a:tag("streamhost",e):up();
end
self.stream:send_iq(a,function(a)
if a.attr.type=="error"then
local a,o,t=a:get_error();
e:event("connection-failed",{conn=e,type=a,condition=o,text=t});
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
function n(i,e,t,a,o)
local t=h.sha1(t..a..o);
local function o()
e:unhook("connected",o);
return true;
end
local function n(t)
e:unhook("incoming-raw",n);
if t:sub(1,2)~="\005\000"then
return e:event("error","connection-failure");
end
e:event("connected");
return true;
end
local function i(a)
e:unhook("incoming-raw",i);
if a~="\005\000"then
local t="version-mismatch";
if a:sub(1,1)=="\005"then
t="authentication-failure";
end
return e:event("error",t);
end
e:send(string.char(5,1,0,3,#t)..t.."\0\0");
e:hook("incoming-raw",n,100);
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
local a=require"util.uuid".generate;
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
function e:jingle(o)
return verse.eventable(setmetatable(base or{
role="initiator";
peer=o;
sid=a();
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
local s,h;
for t in r:childtags()do
if t.name=="content"and t.attr.xmlns==o then
local i=t:child_with_name("description");
local o=i.attr.xmlns;
if o then
local e=e:event("jingle/content/"..o,a,i);
if e then
s=e;
end
end
local o=t:child_with_name("transport");
local i=o.attr.xmlns;
h=e:event("jingle/transport/"..i,a,o);
if s and h then
d=t;
break;
end
end
end
if not s then
e:send(n.error_reply(i,"cancel","feature-not-implemented","The specified content is not supported"));
return;
end
if not h then
e:send(n.error_reply(i,"cancel","feature-not-implemented","The specified transport is not supported"));
return;
end
e:send(n.reply(i));
a.content_tag=d;
a.creator,a.name=d.attr.creator,d.attr.name;
a.content,a.transport=s,h;
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
function t:send_command(a,e,t)
local e=n.iq({to=self.peer,type="set"})
:tag("jingle",{
xmlns=o,
sid=self.sid,
action=a,
initiator=self.role=="initiator"and self.stream.jid or nil,
responder=self.role=="responder"and self.jid or nil,
}):add_child(e);
if not t then
self.stream:send(e);
else
self.stream:send_iq(e,t);
end
end
function t:accept(a)
local t=n.iq({to=self.peer,type="set"})
:tag("jingle",{
xmlns=o,
sid=self.sid,
action="session-accept",
responder=e.jid,
})
:tag("content",{creator=self.creator,name=self.name});
local o=self.content:generate_accept(self.content_tag:child_with_name("description"),a);
t:add_child(o);
local a=self.transport:generate_accept(self.content_tag:child_with_name("transport"),a);
t:add_child(a);
local a=self;
e:send_iq(t,function(t)
if t.attr.type=="error"then
local a,t,a=t:get_error();
e:error("session-accept rejected: %s",t);
return false;
end
a.transport:connect(function(t)
e:warn("CONNECTED (receiver)!!!");
a.state="active";
a:event("connected",t);
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
local e,a,t=e:get_error();
return self:event("error",{type=e,condition=a,text=t});
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
local i=require"ltn12";
local s=package.config:sub(1,1);
local a="urn:xmpp:jingle:apps:file-transfer:1";
local o="http://jabber.org/protocol/si/profile/file-transfer";
function verse.plugins.jingle_ft(t)
t:hook("ready",function()
t:add_disco_feature(a);
end,10);
local n={type="file"};
function n:generate_accept(t,e)
if e and e.save_file then
self.jingle:hook("connected",function()
local e=i.sink.file(io.open(e.save_file,"w+"));
self.jingle:set_sink(e);
end);
end
return t;
end
local n={__index=n};
t:hook("jingle/content/"..a,function(t,e)
local e=e:get_child("offer"):get_child("file",o);
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
:tag("file",{xmlns=o,
name=e.filename,
size=e.size,
date=t,
hash=e.hash,
})
:tag("desc"):text(e.description or"");
end);
function t:send_file(n,t)
local e,a=io.open(t);
if not e then return e,a;end
local a=e:seek("end",0);
e:seek("set",0);
local o=i.source.file(e);
local e=self:jingle(n);
e:offer("file",{
filename=t:match("[^"..s.."]+$");
size=a;
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
local s=require"util.sha1".sha1;
local r=require"util.uuid".generate;
local function h(e,n)
local function o()
e:unhook("connected",o);
return true;
end
local function a(t)
e:unhook("incoming-raw",a);
if t:sub(1,2)~="\005\000"then
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
e:send(string.char(5,1,0,3,#n)..n.."\0\0");
e:hook("incoming-raw",a,100);
return true;
end
e:hook("connected",o,200);
e:hook("incoming-raw",i,100);
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
local t,a=e:connect(
e.streamhosts[e.current_host].host,
e.streamhosts[e.current_host].port
);
if not t then
e:debug("Error connecting to proxy (%s:%s): %s",
e.streamhosts[e.current_host].host,
e.streamhosts[e.current_host].port,
a
);
else
e:debug("Connecting...");
end
h(e,i);
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
local e=s(self.s5b_sid..self.peer..e.jid,true);
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
local e=s(self.s5b_sid..e.jid..self.peer,true);
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
local n=require("mime").b64
local i=require("util.sha1").sha1
local e="http://jabber.org/protocol/disco";
local h=e.."#info";
local s=e.."#items";
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
local function o(t,e)
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
local function t(t,e)
return t.var<e.var
end
local function r()
table.sort(e.disco.info.identities,o)
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
return(n(i(t)))
end
setmetatable(e.caps,{
__call=function(...)
local t=r()
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
function e:remove_disco_feature(a)
for e,t in ipairs(self.disco.info.features)do
if t.var==a then
table.remove(self.disco.info.features,e);
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
function e:jid_has_identity(e,a,t)
local o=self.disco.cache[e];
if not o then
return nil,"no-cache";
end
local e=self.disco.cache[e].identities;
if t then
return e[a.."/"..t]or false;
end
for e in pairs(e)do
if e:match("^(.*)/")==a then
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
function e:get_local_services(o,a)
local e=self.disco.cache[self.host];
if not(e)or not(e.items)then
return nil,"no-cache";
end
local t={};
for i,e in ipairs(e.items)do
if self:jid_has_identity(e.jid,o,a)then
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
function e:disco_info(e,t,n)
local a=verse.iq({to=e,type="get"})
:tag("query",{xmlns=h,node=t});
self:send_iq(a,function(i)
if i.attr.type=="error"then
return n(nil,i:get_error());
end
local a,o={},{};
for e in i:get_child("query",h):childtags()do
if e.name=="identity"then
a[e.attr.category.."/"..e.attr.type]=e.attr.name or true;
elseif e.name=="feature"then
o[e.attr.var]=true;
end
end
if not self.disco.cache[e]then
self.disco.cache[e]={nodes={}};
end
if t then
if not self.disco.cache[e].nodes[t]then
self.disco.cache[e].nodes[t]={nodes={}};
end
self.disco.cache[e].nodes[t].identities=a;
self.disco.cache[e].nodes[t].features=o;
else
self.disco.cache[e].identities=a;
self.disco.cache[e].features=o;
end
return n(self.disco.cache[e]);
end);
end
function e:disco_items(t,a,i)
local o=verse.iq({to=t,type="get"})
:tag("query",{xmlns=s,node=a});
self:send_iq(o,function(o)
if o.attr.type=="error"then
return i(nil,o:get_error());
end
local e={};
for t in o:get_child("query",s):childtags()do
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
local h=r()
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
for t,a in ipairs(t)do
local t=e.disco.cache[a.jid];
if t then
for t in pairs(t.identities)do
local t,o=t:match("^(.*)/(.*)$");
e:event("disco/service-discovered/"..t,{
type=o,jid=a.jid;
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
local i="http://jabber.org/protocol/pubsub";
local o=i.."#event";
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
function e:hook_pep(t,o,a)
e:hook("pep/"..t,o,a);
e:add_disco_feature(t.."+notify");
end
function e:unhook_pep(t,a)
e:unhook("pep/"..t,a);
local a=e.events._handlers["pep/"..t];
if not(a)or#a==0 then
e:remove_disco_feature(t.."+notify");
end
end
function e:publish_pep(t,a)
local t=verse.iq({type="set"})
:tag("pubsub",{xmlns=i})
:tag("publish",{node=a or t.attr.xmlns})
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
e:disco_items(a,t,function(t)
e:debug("adhoc list returned")
local a={};
for o,t in ipairs(t)do
a[t.node]=t.name;
end
e:debug("adhoc calling callback")
return o(a);
end);
end
function e:execute_command(t,o,i)
local e=setmetatable({
stream=e,jid=t,
command=o,callback=i
},a);
return e:execute();
end
local function s(t,e)
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
local function i(t)
local a=t.tags[1];
local a=a.attr.node;
local a=o[a];
if not a then return;end
if not s(t.attr.from,a.permission)then
e:send(verse.error_reply(t,"auth","forbidden","You don't have permission to execute this command"):up()
:add_child(a:cmdtag("canceled")
:tag("note",{type="error"}):text("You don't have permission to execute this command")));
return true
end
return n.handle_cmd(a,{send=function(t)return e:send(t)end},t);
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
local a=require"util.logger".init("httpclient_listener");
local i=require"net.connlisteners".register;
local e={};
local t={};
local t={default_port=80,default_mode="*a"};
function t.onincoming(t,o)
local e=e[t];
if not e then
a("warn","Received response from connection %s with no request attached!",tostring(t));
return;
end
if o and e.reader then
e:reader(o);
end
end
function t.ondisconnect(t,o)
local a=e[t];
if a and o~="closed"then
a:reader(nil);
end
e[t]=nil;
end
function t.register_request(o,t)
a("debug","Attaching request %s to connection %s",tostring(t.id or t),tostring(o));
e[o]=t;
end
i("httpclient",t);
end)
package.preload['net.connlisteners']=(function(...)
local d=(CFG_SOURCEDIR or".").."/net/";
local r=require"net.server";
local o=require"util.logger".init("connlisteners");
local s=tostring;
local h,i,n=
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
local n,i=i(h,d..t:gsub("[^%w%-]","_").."_listener.lua");
if not n then
o("error","Error while loading listener '%s': %s",s(t),s(i));
return nil,i;
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
local f=require"socket"
local c=require"mime"
local d=require"socket.url"
local o=require"util.httpstream".new;
local m=require"net.server"
local e=require"net.connlisteners".get;
local s=e("httpclient")or error("No httpclient listener!");
local n,i=table.insert,table.concat;
local h,r=pairs,ipairs;
local a,u,w,v,y,p,t=
tonumber,tostring,xpcall,select,debug.traceback,string.char,string.format;
local l=require"util.logger".init("http");
module"http"
function urlencode(e)return e and(e:gsub("%W",function(e)return t("%%%02x",e:byte());end));end
function urldecode(e)return e and(e:gsub("%%(%x%x)",function(e)return p(a(e,16));end));end
local function a(e)
return e and(e:gsub("%W",function(e)
if e~=" "then
return t("%%%02x",e:byte());
else
return"+";
end
end));
end
function formencode(t)
local e={};
for o,t in r(t)do
n(e,a(t.name).."="..a(t.value));
end
return i(e,"&");
end
local function p(e,a,t)
if not e.parser then
local function a(t)
if e.callback then
for t,a in h(t)do e[t]=a;end
e.callback(t.body,t.code,e);
e.callback=nil;
end
destroy_request(e);
end
local function t(t)
if e.callback then
e.callback(t or"connection-closed",0,e);
e.callback=nil;
end
destroy_request(e);
end
local function i()
return e;
end
e.parser=o(a,t,"client",i);
end
e.parser:feed(a);
end
local function b(e)l("error","Traceback[http]: %s: %s",u(e),y());end
function request(e,t,r)
local e=d.parse(e);
if not(e and e.host)then
r(nil,0,e);
return nil,"invalid-url";
end
if not e.path then
e.path="/";
end
local d,o;
local a={["Host"]=e.host,["User-Agent"]="Prosody XMPP Server"}
if e.userinfo then
a["Authorization"]="Basic "..c.b64(e.userinfo);
end
if t then
d=t.headers;
e.onlystatus=t.onlystatus;
o=t.body;
if o then
e.method="POST ";
a["Content-Length"]=u(#o);
a["Content-Type"]="application/x-www-form-urlencoded";
end
if t.method then e.method=t.method;end
end
e.handler,e.conn=m.wrapclient(f.tcp(),e.host,e.port or 80,s,"*a");
e.write=function(...)return e.handler:write(...);end
e.conn:settimeout(0);
local u,t=e.conn:connect(e.host,e.port or 80);
if not u and t~="timeout"then
r(nil,0,e);
return nil,t;
end
local t={e.method or"GET"," ",e.path," HTTP/1.1\r\n"};
if e.query then
n(t,4,"?");
n(t,5,e.query);
end
e.write(i(t));
local t={[2]=": ",[4]="\r\n"};
if d then
for o,n in h(d)do
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
e.callback=function(o,t,a)l("debug","Calling callback, status %s",t or"---");return v(2,w(function()return r(o,t,a)end,b));end
e.reader=p;
e.state="status";
s.register_request(e.handler,e);
return e;
end
function destroy_request(e)
if e.conn then
e.conn=nil;
e.handler:close()
s.ondisconnect(e.handler,"closed");
end
end
_M.urlencode=urlencode;
return _M;
end)
package.preload['verse.bosh']=(function(...)
local n=require"core.xmlhandlers";
local i=require"util.stanza";
require"net.httpclient_listener";
local a=require"net.http";
local e=setmetatable({},{__index=verse.stream_mt});
e.__index=e;
local h="http://etherx.jabber.org/streams";
local s="http://jabber.org/protocol/httpbind";
local o=5;
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
self.bosh_outgoing_buffer[#self.bosh_outgoing_buffer+1]=i.clone(e);
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
for a,o in ipairs(t)do
e:add_child(o);
t[a]=nil;
end
self:_make_request(e);
else
self:debug("Decided not to flush.");
end
end
function e:_make_request(t)
local e,t=a.request(self.bosh_url,{body=tostring(t)},function(i,e,a)
if e~=0 then
self.inactive_since=nil;
return self:_handle_response(i,e,a);
end
local e=os.time();
if not self.inactive_since then
self.inactive_since=e;
elseif e-self.inactive_since>self.bosh_max_inactivity then
return self:_disconnected();
else
self:debug("%d seconds left to reconnect, retrying in %d seconds...",
self.bosh_max_inactivity-(e-self.inactive_since),o);
end
timer.add_task(o,function()
self:debug("Retrying request...");
for e,t in ipairs(self.bosh_waiting_requests)do
if t==a then
table.remove(self.bosh_waiting_requests,e);
break;
end
end
self:_make_request(t);
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
a.request(self.bosh_url,{body=tostring(e)},function(t,e)
if e==0 then
return self:_disconnected();
end
local e=self:_parse_response(t)
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
for a,t in ipairs(self.bosh_waiting_requests)do
if t==e then
self.bosh_waiting_requests[a]=nil;
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
if e.attr.xmlns==h then
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
handlestanza=function(e,t)e.payload:add_child(t);end;
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
xmlns=s;
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
package.preload['verse.client']=(function(...)
local t=require"verse";
local o=t.stream_mt;
local h=require"util.jid".split;
local s=require"net.adns";
local r=require"lxp";
local a=require"util.stanza";
t.message,t.presence,t.iq,t.stanza,t.reply,t.error_reply=
a.message,a.presence,a.iq,a.stanza,a.reply,a.error_reply;
local l=require"core.xmlhandlers";
local n="http://etherx.jabber.org/streams";
local function d(e,t)
return e.priority<t.priority or(e.priority==t.priority and e.weight>t.weight);
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
local e=r.new(l(self,i),"\1");
self.parser=e;
self.notopen=true;
return true;
end
function o:connect_client(e,a)
self.jid,self.password=e,a;
self.username,self.host,self.resource=h(e);
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
s.lookup(function(a)
if a then
local e={};
self.srv_hosts=e;
for a,t in ipairs(a)do
table.insert(e,t.srv);
end
table.sort(e,d);
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
function o:send_iq(t,a)
local e=self:new_id();
self.tracked_iqs[e]=a;
t.attr.id=e;
self:send(t);
end
function o:new_id()
self.curr_id=self.curr_id+1;
return tostring(self.curr_id);
end
end)
package.preload['verse.component']=(function(...)
local a=require"verse";
local t=a.stream_mt;
local h=require"util.jid".split;
local l=require"lxp";
local o=require"util.stanza";
local d=require"util.sha1".sha1;
a.message,a.presence,a.iq,a.stanza,a.reply,a.error_reply=
o.message,o.presence,o.iq,o.stanza,o.reply,o.error_reply;
local r=require"core.xmlhandlers";
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
local e=l.new(r(self,n),"\1");
self.parser=e;
self.notopen=true;
return true;
end
function t:connect_component(e,n)
self.jid,self.password=e,n;
self.username,self.host,self.resource=h(e);
function self.data(a,e)
local o,a=self.parser:parse(e);
if o then return;end
t:debug("debug","Received invalid XML (%s) %d bytes: %s",tostring(a),#e,e:sub(1,300):gsub("[\r\n]+"," "));
t:close("xml-not-well-formed");
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
local t=e.tags[1]and e.tags[1].attr.xmlns;
if t then
ret=self:event("iq/"..t,e);
if not ret then
ret=self:event("iq",e);
end
end
if ret==nil then
self:send(a.error_reply(e,"cancel","service-unavailable"));
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
local e=d(self.stream_id..n,true);
self:send(o.stanza("handshake",{xmlns=i}):text(e));
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
self:send(o.stanza("stream:stream",{to=self.host,["xmlns:stream"]='http://etherx.jabber.org/streams',
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
local a=require"net.server";
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
a.setlogger(t);
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
local function o(t)
e.log("error","Error: %s",t);
e.log("error","Traceback: %s",debug.traceback());
end
function e.set_error_handler(e)
o=e;
end
function e.loop()
return xpcall(a.loop,o);
end
function e.step()
return xpcall(a.step,o);
end
function e.quit()
return a.setquitting(true);
end
function t:connect(t,o)
t=t or"localhost";
o=tonumber(o)or 5222;
local i=socket.tcp()
i:settimeout(0);
local n,e=i:connect(t,o);
if not n and e~="timeout"then
self:warn("connect() to %s:%d failed: %s",t,o,e);
return self:event("disconnected",{reason=e})or false,e;
end
local t=a.wrapclient(i,t,o,new_listener(self),"*a");
if not t then
self:warn("connection initialisation failed: %s",e);
return self:event("disconnected",{reason=e})or false,e;
end
self.conn=t;
local e,o=t.write,tostring;
self.send=function(i,a)return e(t,o(a));end
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
function t:unhook(t,e)
return self.events.remove_handler(t,e);
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
local a,e=e.plugins[t](self);
if a then
self:debug("Loaded %s plugin",t);
else
self:warn("Failed to load %s plugin: %s",t,e);
end
end
return self;
end
function new_listener(e)
local t={};
function t.onconnect(t)
e.connected=true;
e.send=function(a,e)a:debug("Sending data: "..tostring(e));return t:write(tostring(e));end;
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
