-- Add here job:
licenses_add("miner")
licenses_add("farmer")
licenses_add("hunter")
licenses_add("builder")

-- Change here Countdown:
DINGSTIME = 36000

minetest.register_chatcommand("job", {
  privs = {
      interact = true,
  },

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
      if minetest.get_gametime() - aqtime < DINGSTIME then
        minetest.chat_send_player(player, "You can only change your job every " .. DINGSTIME .. " seconds!")
      else
        local changed = true
        --- Add here job:
        if job == "miner" then
          licenses_unassign(player, "farmer")
          licenses_unassign(player, "hunter")
          licenses_unassign(player, "builder")
        elseif job == "farmer" then
          licenses_unassign(player, "miner")
          licenses_unassign(player, "hunter")
          licenses_unassign(player, "builder")
        elseif job == "hunter" then
          licenses_unassign(player, "miner")
          licenses_unassign(player, "farmer")
          licenses_unassign(player, "builder")
        elseif job == "builder" then
          licenses_unassign(player, "miner")
          licenses_unassign(player, "farmer")
          licenses_unassign(player, "hunter")
        else
          minetest.chat_send_player(player, "Job not known")
          changed = false
        end
        if changed then
          licenses_assign(player, job)
          minetest.chat_send_player(player, "You are "..job.." now")
          aqtime= minetest.get_gametime()
          pmeta:set_int("job:aqtime", aqtime)
          pmeta:set_string("job:job", job)
        end
      end
    end
    if param == "info" then
      minetest.chat_send_player(player, "You are "..pmeta:get_string("job:job"))
    elseif mode ~= "acquire" and job ~= " acquire" then
      minetest.chat_send_player(player, ..
      "job acquire <job_name>: Aqcuire a job" ..
      -- Add here job:
      "\njobs: miner, farmer, hunter, builder"..
      "\njob info: Displays your current job")

    end
  end
})
