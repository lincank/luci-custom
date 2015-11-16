--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.admin.index", package.seeall)

function index()
	local root = node()
	if not root.target then
		root.target = alias("admin")
		root.index = true
	end

	local page   = node("admin")
	page.target  = firstchild()
	page.title   = _("Administration")
	page.order   = 10
	page.sysauth = "root"
	page.sysauth_authenticator = "htmlauth"
	page.ucidata = true
	page.index = true

	-- Empty services menu to be populated by addons
	entry({"admin", "services"}, firstchild(), _("Services"), 40).index = true

	entry({"admin", "logout"}, call("action_logout"), _("Logout"), 90)
	entry({"admin", "one_click"}, call("action_oneclick"), _("一键检测"), 85)
	entry({"admin", "migrate_server"}, call("action_migrate_server"), _("切换服务器"), 87)
end

function action_migrate_server()
	local preform = luci.http.formvalue("perform")
	if preform then
  	origin_url = luci.sys.exec("mpw turn")
		url = string.gsub(origin_url, '+', '%%2B')
	  return luci.http.redirect('http://http://service.penewave.com/' .. url)
  end
	luci.template.render("migrate_server/index")
end


function action_oneclick()
	local preform = luci.http.formvalue("perform")
	if preform then
  	luci.sys.exec("/etc/init.d/jc.shell")
  	m = io.popen("cat /root/report")
  	cable = m:read() or "something wrong,try again"
  	baidu = m:read() or " something wrong, try again"
  	google = m:read() or "NO"
		m:close()
  end
	luci.template.render("one_click/index", {cable=cable, baidu=baidu, google=google})
end


function action_logout()
	local dsp = require "luci.dispatcher"
	local sauth = require "luci.sauth"
	if dsp.context.authsession then
		sauth.kill(dsp.context.authsession)
		dsp.context.urltoken.stok = nil
	end

	luci.http.header("Set-Cookie", "sysauth=; path=" .. dsp.build_url())
	luci.http.redirect(luci.dispatcher.build_url())
end
