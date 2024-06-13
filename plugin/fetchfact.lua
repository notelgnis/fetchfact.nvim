vim.api.nvim_create_user_command('FetchFact', function(args)
    local command = args.args
    if command == 'new' then
        require('fetchfact').new()
    else
        print 'Supported commands: new'
    end
end, {
    nargs = 1,
    complete = function(arglead, _, _)
        local completions = {}
        local options = { 'new' }

        for _, opt in ipairs(options) do
            if opt:match('^' .. arglead) then
                table.insert(completions, opt)
            end
        end

        return completions
    end,
})
