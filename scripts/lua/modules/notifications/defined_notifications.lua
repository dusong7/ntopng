--
-- (C) 2020 - ntop.org
--

local page_utils = require("page_utils")
local predicates = require("predicates_defined_notifications")

-- Placeholder for pages/excluded, subpages/excluded tables
local EMPTY_PAGES = {}
local pages = page_utils.menu_entries

--- Define a new notification is easy, here is 3 steps to follow:
--- 1) choose a new notification id that must be unique
--- 2) define the dismissability of the notification with `dismissable` field
--- 3) define a predicate function that generate the ui for the notification
--- Following there is a structure of a notification:
--[[
    {
        id: string,
        dismissable: boolean,
        pages: array of page keys,
        subpages: table of arrays of subpages,
        excluded_pages: array of page keys
        excluded_subpages: table of arrays of subpages
    }
]]--

--- id: The id field defines an unique notification to be displayed. This field is used
--- to make the Redis Key for the notification status (the dimiss status)

--- dismissable: as the name suggest, this field indicates if a notifican can be dismissed by the user

--- pages: this is an array of page keys that are used to show the notification to the right page
--- subpages: this is a table containing key/value pairs where key='page entry key' and the
--- value is an array of subpages string, for example ({['if_stats'] = {'DHCP', 'config', ...}})
--- Be aware that the subpage is obtained by the _GET 'page' param.

--- excluded_pages: is the opposite of pages
--- excluded_subpages: is the opposite of subpages

--- It's a good convention to put the predicate functions inside the module: `predicates_defined_notifications`

local defined_notifications = {
    {
        id = "contribute",
        dismissable = true,
        predicate = predicates.contribute,
        pages = EMPTY_PAGES,
        subpages = EMPTY_PAGES,
        excluded_pages = {pages.preferences.key}
    },
    {
        id = "about_page",
        dismissable = false,
        predicate = predicates.about_page,
        pages = {pages.about.key},
        subpages = EMPTY_PAGES,
        excluded_pages = EMPTY_PAGES
    },
    {
        id = "hosts_geomap",
        dismissable = true,
        predicate = predicates.hosts_geomap,
        pages = {pages.geo_map.key},
        subpages = { [pages.hosts.key] = {'geomap'} },
        excluded_pages = EMPTY_PAGES
    },
    {
        id = "restart_required",
        dismissable = false,
        predicate = predicates.restart_required,
        pages = EMPTY_PAGES,
        subpages = EMPTY_PAGES,
        excluded_pages = EMPTY_PAGES
    },
    {
        id = "flow_dump",
        dismissable = false,
        predicate = predicates.flow_dump,
        pages = EMPTY_PAGES,
        subpages = EMPTY_PAGES,
        excluded_pages = EMPTY_PAGES
    },
    {
        id = "remote_probe_clock_drift",
        dismissable = false,
        predicate = predicates.remote_probe_clock_drift,
        pages = EMPTY_PAGES,
        subpages = EMPTY_PAGES,
        excluded_pages = EMPTY_PAGES
    },
    {
        id = "temp_working_dir",
        dismissable = true,
        predicate = predicates.temp_working_dir,
        pages = EMPTY_PAGES,
        subpages = EMPTY_PAGES,
        excluded_pages = EMPTY_PAGES
    },
    {
        id = "geo_ip",
        dismissable = true,
        predicate = predicates.geo_ip,
        pages = EMPTY_PAGES,
        subpages = EMPTY_PAGES,
        excluded_pages = EMPTY_PAGES
    },
    {
        id = "update_ntopng",
        dismissable = false,
        predicate = predicates.update_ntopng,
        pages = EMPTY_PAGES,
        subpages = EMPTY_PAGES,
        excluded_pages = EMPTY_PAGES
    },
    {
        id = "too_many_hosts",
        dismissable = false,
        predicate = predicates.too_many_hosts,
        pages = EMPTY_PAGES,
        subpages = EMPTY_PAGES,
        excluded_pages = EMPTY_PAGES
    },
    {
        id = "too_many_flows",
        dismissable = false,
        predicate = predicates.too_many_flows,
        pages = EMPTY_PAGES,
        subpages = EMPTY_PAGES,
        excluded_pages = EMPTY_PAGES
    },
    {
        id = "DHCP_range",
        dismissable = true,
        predicate = predicates.DHCP,
        pages = {pages.interfaces_status.key},
        subpages = EMPTY_PAGES,
        excluded_pages = {pages.preferences.key},
        excluded_subpages = {[pages.interfaces_status.key] = {'dhcp', 'config'}}
    },
    {
        id = "DHCP_monitoring",
        dismissable = true,
        predicate = predicates.DHCP,
        pages = EMPTY_PAGES,
        excluded_pages = {pages.preferences.key},
    },
    {
        id = "flow_snmp_ratio",
        dismissable = true,
        predicate = predicates.exporters_SNMP_ratio_column,
        pages = {pages.flow_exporters.key},
        subpages = EMPTY_PAGES,
        excluded_pages = EMPTY_PAGES,
        excluded_subpages = EMPTY_PAGES
    }
}

return defined_notifications