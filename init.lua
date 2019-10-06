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


minetest.register_chatcommand("job", {
  privs = {
      interact = true,
  },
  params = "acquire/info <job>",
  description = "Handles your current job.\n"..
  "job acquire <job_name>: Aqcuire a job" ..
  -- Add here job:
  "\njobs: miner, farmer, builder"..
  "\njob info: Displays your current job",
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
      "job acquire <job_name>: Aqcuire a job" ..
      -- Add here job:
      "\njobs: miner, farmer, builder"..
      "\njob info: Displays your current job")

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
