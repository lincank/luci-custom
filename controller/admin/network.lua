module("luci.controller.admin.network", package.seeall)

function index()
	entry({"admin", "network"}, cbi("admin_network/wificustom"), _("Wifi设置"), 15)
end
