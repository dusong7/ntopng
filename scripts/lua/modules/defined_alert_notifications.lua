--
-- (C) 2020 - ntop.org
--
local dirs = ntop.getDirs()
local info = ntop.getInfo()
local prefs = ntop.getPrefs()

local defined_alert_notifications = {}
local telemetry_utils = require("telemetry_utils")
local alert_notification = require("alert_notification")

local function create_geo_ip_alert_notification()

    local title = i18n("geo_map.geo_ip")
    local description = i18n("geolocation_unavailable", {url = "https://github.com/ntop/ntopng/blob/dev/doc/README.geolocation.md", target = "_blank", icon = "fas fa-external-link-alt"})

    return alert_notification:create("geoip_alert", title, description, "warning")
end

local function create_contribute_alert_notification()

    local title = i18n("about.contribute_to_project")
    local description = i18n("about.telemetry_data_opt_out_msg", {tel_url=ntop.getHttpPrefix().."/lua/telemetry.lua", ntop_org="https://www.ntop.org/"})
    local action = {
        url = ntop.getHttpPrefix() .. '/lua/admin/prefs.lua?tab=telemetry',
        title = i18n("configure")
    }

    return alert_notification:create("contribute_alert", title, description, "info", action, "/lua/admin/prefs.lua")
end

local function create_tempdir_alert_notification()

    local title = i18n("warning")
    local description = i18n("about.datadir_warning")
    local action = {
        url = "https://www.ntop.org/support/faq/migrate-the-data-directory-in-ntopng/"
    }

    return alert_notification:create("tempdir_alert", title, description, "warning", action)
end

local function create_update_ntopng_notification(body)

    local title = i18n("update")
    return alert_notification:create("update_alert", title, body, "info")
end

local function create_too_many_flows_notification(level)

    local title = i18n("too_many_flows")
    local desc = i18n("about.you_have_too_many_flows", {product=info["product"]})

    return alert_notification:create("toomanyflows_alert", title, desc, level)
end

-- ##################################################################

--- Create an instance for the geoip alert notification
--- if the user doesn't have geoIP installed
--- @param container table The table where the notification will be inserted
function defined_alert_notifications.geo_ip(container)

    if isAdministrator() and not ntop.hasGeoIP() then
        table.insert(container, create_geo_ip_alert_notification())
    end

end

--- Create an instance for the temp working directory alert
--- if ntopng is running inside /var/tmp
--- @param container table The table where the notification will be inserted
function defined_alert_notifications.temp_working_dir(container)

    if (dirs.workingdir == "/var/tmp/ntopng") then
        table.insert(container, create_tempdir_alert_notification())
    end

end

--- Create an instance for contribute alert notification
--- @param container table The table where the notification will be inserted
function defined_alert_notifications.contribute(container)

    if (not info.oem) and (not telemetry_utils.dismiss_notice()) then
        table.insert(container, create_contribute_alert_notification())
    end

end

function defined_alert_notifications.update_ntopng(container)

    -- check if ntopng is oem and the user is an Administrator
    local is_not_oem_and_administrator = isAdministrator() and not info.oem
    local message = check_latest_major_release()

    if is_not_oem_and_administrator and not isEmptyString(message) then
        table.insert(container, create_update_ntopng_notification(message))
    end

end

function defined_alert_notifications.too_many_flows(container)

    local level = nil
    local flows = interface.getNumFlows()
    local flows_pctg = math.floor(1 + ((flows * 100) / prefs.max_num_flows))

    local ALARM_THRESHOLD_LOW = 60
    local ALARM_THRESHOLD_HIGH = 90;

    if (flows_pctg >= ALARM_THRESHOLD_LOW and flows_pctg <= ALARM_THRESHOLD_HIGH) then
        level = "warning"
    elseif (flows_pctg > ALARM_THRESHOLD_HIGH) then
        level = "danger"
    end

    if (level ~= nil) then
        table.insert(container, create_too_many_flows_notification(level))
    end

end

return defined_alert_notifications