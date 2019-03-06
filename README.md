# Minetest-Mod: jobsystem
Github: https://github.com/Jean28518/minetest_jobsystem

This mod adds a jobsystem to your server. You can only have one job on the same time.
You can change your job after 10 hours servertime. That can be changed (see below).

## For what can I use this mod?
To handle the jobs of the players. On my server I use this mod in combination with adminshop, which supports licenses (jobsystem is based on licenses). So a player in a specific job can sell/buy some items to better prices for example.

licenses mod on GitHub: https://github.com/Jean28518/minetest_licenses

## How to use:
`job` Display help

`job info` Display your current job

`job acquire <job_name>`


### Pre Configured Jobs:
`miner`, `farmer`,`hunter`, `builder`

## How to configure:
in `init.lua` you can change the countdown-time (default is 10 hours (36000 seconds))
by changing the value of `DINGSTIME`. You can set it to zero if you want to disable
the mecanism.

You could also add custom jobs by adding your job to the sections. `-- Add here job:`.
*(Dont forget to unassign your new job on every other case, because with this mod a player should have at least only one job assigned)*
