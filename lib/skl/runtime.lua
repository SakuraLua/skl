local runtime = {}

function runtime.run_sec()
    return os.time() - SKL_BOOT_TIME
end

function runtime.run_min()
    return math.floor(runtime.run_sec() / 60)
end

function runtime.sum_sec()
    return runtime.run_sec() + SAVEDATA["sum_sec"]
end

function runtime.sum_min()
    return math.floor((runtime.run_sec() + SAVEDATA["sum_sec"]) / 60)
end

SYSTEMFUNC = SYSTEMFUNC or {}
SYSTEMFUNC["sum_sec"] = runtime.sum_sec
SYSTEMFUNC["run_sec"] = runtime.run_sec
SYSTEMFUNC["sum_min"] = runtime.sum_min
SYSTEMFUNC["run_min"] = runtime.run_min

return runtime