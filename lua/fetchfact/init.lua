local job = require 'plenary.job'
local url = 'https://api.api-ninjas.com/v1/facts'
local facts = {}
local timer_max_count = 25
local timer_id = nil

local _opts = {
    cache_file_path = vim.fn.expand '~/.cache/facts_cache.json',
    config_file_path = vim.fn.expand '~/.config/.facts_api_key',
    min_facts = 2,
    max_facts = 10,
}

local read_api_key = function()
    local file = io.open(_opts.config_file_path, 'r')
    local key = 'No Key Found'
    if file then
        key = file:read '*l'
        file:close()
    end
    return key
end

local api_key = read_api_key()

local load_facts = function()
    local file = io.open(_opts.cache_file_path, 'w')
    if file then
        file:write(vim.fn.json_encode(facts))
        file:close()
    end
end

local check_new_facts = function()
    if not facts or timer_max_count == 0 then
        vim.fn.timer_stop(timer_id)
        facts = {}
        timer_id = nil
        return
    end

    if #facts >= _opts.max_facts then
        load_facts()
        facts = nil
        return
    end

    timer_max_count = timer_max_count - 1
end

local fetch_fact_async = function()
    for _ = 1, _opts.max_facts do
        local args = {
            '-s',
            '-H',
            string.format('X-Api-Key: %s', api_key),
            '-H',
            'Content-Type: application/json',
            url,
        }

        job:new({
            command = 'curl',
            args = args,
            on_start = function()
                if not timer_id then
                    timer_id = vim.fn.timer_start(500, check_new_facts, { ['repeat'] = -1 })
                end
            end,
            on_exit = function(j, exit_code)
                if exit_code ~= 0 then
                    facts = nil
                    return
                end

                if not j:result() then
                    facts = nil
                    return
                end

                local fact = j:result()[1]

                if fact then
                    fact = fact:gsub('^%[', ''):gsub('%]$', '')
                    local extracted_fact = fact:match '{"fact": "(.-)"}'

                    if not facts then
                        facts = {}
                    end

                    table.insert(facts, extracted_fact)
                end
            end,
        }):start()
    end
end

local fetch_fact = function()
    local curl_cmd = string.format('curl -s -H "X-Api-Key: %s" -H "Content-Type: application/json" "%s"', api_key, url)
    local result = vim.fn.system(curl_cmd)
    if vim.v.shell_error == 0 then
        local r = vim.fn.json_decode(result)
        return r[1].fact
    else
        return 'Well, nobody’s perfect'
    end
end

local M = {}

M.setup = function(opts)
    if opts then
        for k, v in pairs(opts) do
            if v ~= nil then
                if k == 'cache_file_path' or k == 'config_file_path' then
                    _opts[k] = vim.fn.expand(v)
                else
                    _opts[k] = v
                end
            end
        end
    end
end

M.get_fact = function()
    local file = io.open(_opts.cache_file_path, 'r')
    if file then
        facts = vim.fn.json_decode(file:read '*all')
        file:close()
    end

    if #facts == 0 then
        local emergency_fact = fetch_fact()
        fetch_fact_async()
        return emergency_fact
    end

    local fact = facts[1]
    table.remove(facts, 1)
    if #facts < _opts.min_facts then
        fetch_fact_async()
    end

    load_facts()

    return fact:gsub('\\"', '"')
end

M.new = function()
    print(fetch_fact())
end

return M
