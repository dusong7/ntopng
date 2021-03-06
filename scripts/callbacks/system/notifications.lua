--
-- (C) 2013-20 - ntop.org
--
--

local dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path
package.path = dirs.installdir .. "/scripts/lua/modules/recipients/?.lua;" .. package.path

require "lua_utils"
local recipients = require "recipients"
local periodicity = 3

-- For performace, this script is started in C only one time every hour.
-- A while-loop is implemented inside this script to process notifications
-- every `periodicity` 3 seconds.

while true do
   -- Process notifications every three seconds.

   -- Start time, in milliseconds, used to calculate the duration of the processing of notifications
   local start_ms = ntop.gettimemsec()

   -- Time, in seconds (just strip the decimal part of the number which contains milliseconds), used to decide
   -- when it is time to exit
   local now = math.floor(start_ms)

   -- Do the actual processing
   recipients.process_notifications(now, now + periodicity --[[ deadline --]], periodicity)

   -- End time, in milliseconds, used to calculate the duration of the processing of notifications
   local end_ms = ntop.gettimemsec()

   -- Check if it time to exit the loop
   if ntop.isShutdown() or ntop.getDeadline() - now < 60 --[[ less than 60 seconds from the deadline --]] or ntop.isDeadlineApproaching() --[[ just for safety, should not occur --]] then
      break
   end

   -- Sleep for a time which is three seconds minus the amount of time spent processing notifications
   local nap_ms = (periodicity - (end_ms - start_ms)) * 1000

   -- Only sleep if nap is positive. If negative, it means that the task is late
   if nap_ms > 0 then
      ntop.msleep(nap_ms)
   end
end
