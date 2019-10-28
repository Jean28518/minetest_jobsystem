-- For jobadmin you need the priv "jobadmin"

-- Add here job:
licenses_add("miner")
licenses_add("farmer")
licenses_add("builder")

jobsystem = {}

--------------------------------------------------------------------------------
-- Configuration:
--------------------------------------------------------------------------------
local COOLDOWN_IN_SECONDS = 36000 -- Define here the cooldown time after hireing a new job in Seconds.

-- Advanced Builder
local ADVANCED_BUILDER = false -- Change this to true, if you have jeans_economy activated and want, that a Builder gets money for building blocks.
local ACCOUNTING_PERIOD = 299 -- Unit: Seconds
local REVENUE = 0.1 -- Revenue per builded Block
--------------------------------------------------------------------------------


local buildedBlocks = {}
local ADVANCED_BUILDER = minetest.get_modpath("jeans_economy") and ADVANCED_BUILDER

--------------------------------------------------------------------------------
-- User Command for Job:
--------------------------------------------------------------------------------

minetest.register_chatcommand("job", {
  privs = {
      interact = true,
  },
  params = "acquire/info <job>",
  description = "Handles your current job.\n"..
  "To acquire a Job:"..
  "\n /job acquire <job_name>" ..
  "\n <---->" ..
  "\nAvaible jobs:"..
  -- Add here job:
  "\n miner, farmer, builder"..
  "\n <---->" ..
  "\n Displays your current job:"..
  "\n /job info",
  func = function(player, param)
    local mode, job = param:match('^(%S+)%s(.+)$')
    local pmeta = minetest.get_player_by_name(player):get_meta()
    local aqtime = pmeta:get_int("job:aqtime")
    if  aqtime == nil then
      aqtime = 0
    end
    if job == " acquire" then
      minetest.chat_send_player(player, "You need to specify a job!")
      return
    end
    if mode == "acquire" then
      if minetest.get_gametime() - aqtime < COOLDOWN_IN_SECONDS then
        minetest.chat_send_player(player, "You can only change your job every " .. COOLDOWN_IN_SECONDS .. " seconds!")
      else
        local changed = true
        --- Add here job:
        if job == "miner" then
          licenses_unassign(player, "farmer")
          licenses_unassign(player, "builder")
        elseif job == "farmer" then
          licenses_unassign(player, "miner")
          licenses_unassign(player, "builder")
        elseif job == "builder" then
          licenses_unassign(player, "miner")
          licenses_unassign(player, "farmer")
        else
          minetest.chat_send_player(player, "Job not known")
          changed = false
        end
        if changed then
          licenses_assign(player, job)
          minetest.log("action", player.." acquires the job "..job)
          minetest.chat_send_player(player, "You are "..job.." now")
          aqtime= minetest.get_gametime()
          pmeta:set_int("job:aqtime", aqtime)
          pmeta:set_string("job:job", job)
        end
      end
    end
    if param == "info" then
      local currentjob = pmeta:get_string("job:job")
      if currentjob == "" then
        minetest.chat_send_player(player, "You don't have any job at time!")
      else
        minetest.chat_send_player(player, "You are ".. currentjob)
      end
    elseif mode ~= "acquire" and job ~= " acquire" then
      minetest.chat_send_player(player, ""..
     "To acquire a Job:"..
     "\n /job acquire <job_name>" ..
     "\n <---->" ..
     "\nAvaible jobs:"..
     -- Add here job:
     "\n miner, farmer, builder"..
     "\n <---->" ..
     "\n Displays your current job:"..
     "\n /job info")
   end
 end

})

--------------------------------------------------------------------------------
-- Handle advanced Builder Mode:
--------------------------------------------------------------------------------
if ADVANCED_BUILDER then
  minetest.after(ACCOUNTING_PERIOD, function() jobsystem.accounting() end)
end

function jobsystem.accounting()
  for name, blocks in pairs(buildedBlocks) do
    local payout = math.floor(blocks*REVENUE)
    if payout > 0 then
      jeans_economy_book("!SERVER!", name, payout, "Payout for builded Blocks")
    end
  end
  buildedBlocks = {}
  minetest.after(ACCOUNTING_PERIOD, function() jobsystem.accounting() end)
end

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
  if ADVANCED_BUILDER and licenses_check_player_by_licese(placer:get_player_name(), "builder") then
    if buildedBlocks[placer:get_player_name()] == nil then
      buildedBlocks[placer:get_player_name()] = 1
    else
      buildedBlocks[placer:get_player_name()] = buildedBlocks[placer:get_player_name()] + 1
    end
  end
end)

--------------------------------------------------------------------------------
-- Admin Command for Job:
--------------------------------------------------------------------------------

-- Register the jobadmin command priv

  minetest.register_privilege("jobadmin", {
  description = "Admin can change the Job for Users",
  give_to_singleplayer = false,
  give_to_admin = true,
})

minetest.register_chatcommand("jobadmin", {


  privs = {
      jobadmin = true,
  },
  params = "acquire/info <player> <job>",
  description = "Handles Players current job.\n"..
  "To acquire a Player Job:"..
  "\n /jobadmin acquire <player> <job_name>" ..
  "\n <---->" ..
  "\nAvaible jobs:"..
  -- Add here job:
  "\n miner, farmer, builder"..
  "\n <---->" ..
  "\n Displays Players current job:"..
  "\n /jobadmin info <player>",
  func = function(admin, param)

        -- jobadmin acquire <player> <job>
--------------------------------------------------------------------------------
    local mode, player, job = string.match(param, "(%S+) (%S+) (%S+)")
    if mode == "acquire" and player ~= nil and job ~= nil then
      if not minetest.player_exists(player) then
        minetest.chat_send_player(admin, "Player not found" )
        return
      end
      -- Add here job:
      if job == "miner" then
        licenses.revoke(player, "farmer")
        licenses_unassign(player, "builder")
        licenses.assign(player, "miner")
      elseif job == "farmer" then
        licenses_unassign(player, "miner")
        licenses_unassign(player, "builder")
        licenses.assign(player, "farmer")
      elseif job == "builder" then
        licenses_unassign(player, "miner")
        licenses_unassign(player, "farmer")
        licenses.assign(player, "builder")
      else
        minetest.chat_send_player(admin, "Job not found" )
        return
      end
      minetest.chat_send_player(admin, "Job "..job .." sucessfully assigned to "..player)
      minetest.log("action", admin .. " assigns the job "..job.." to "..player)
      return
    end

    -- jobadmin time_acquire <player> <job>
--------------------------------------------------------------------------------

-- local mode, player, job = string.match(param, "(%S+) (%S+) (%S+)")
-- if mode == "time_acquire" and player ~= nil and job ~= nil then
--  if not minetest.player_exists(player) then
--    minetest.chat_send_player(admin, "Player not found" )
--    return
--  end
--
--  if minetest.get_gametime() - aqtime < COOLDOWN_IN_SECONDS then
--    minetest.chat_send_player(player, "You can only change your job every " .. COOLDOWN_IN_SECONDS .. " seconds!")
--  else
--    local changed = true

  -- Add here job:

--  if job == "miner" then
--    licenses.revoke(player, "farmer")
--    licenses_unassign(player, "builder")
--    licenses.assign(player, "miner")
--  elseif job == "farmer" then
--    licenses_unassign(player, "miner")
--    licenses_unassign(player, "builder")
--    licenses.assign(player, "farmer")
--  elseif job == "builder" then
--    licenses_unassign(player, "miner")
--    licenses_unassign(player, "farmer")
--    licenses.assign(player, "builder")
--  else
--    minetest.chat_send_player(admin, "Job not found" )
--    return
--  end
--  minetest.chat_send_player(admin, "Job "..job .." sucessfully assigned to "..player)
--  minetest.log("action", admin .. " assigns the job "..job.." to "..player)
--  return
--end
--end


    -- jobadmin info <player>
--------------------------------------------------------------------------------
    mode, player = string.match(param, "(%S+) (%S+)")
    if mode == "info" and player ~= nil then
      if not minetest.player_exists(player) then
        minetest.chat_send_player(admin, "Player not found" )
        return
      end

      if licenses.check(player, "miner") then
        minetest.chat_send_player(admin, "Player "..player.." is miner." )
      elseif licenses.check(player, "farmer") then
        minetest.chat_send_player(admin, "Player "..player.." is farmer." )
      elseif licenses.check(player, "builder") then
        minetest.chat_send_player(admin, "Player "..player.." is builder." )
      else
        minetest.chat_send_player(admin, "Player "..player.." has no job yet." )
      end
      return
    end

    minetest.chat_send_player(admin, "For correct use see /help jobadmin" )
  end
})
