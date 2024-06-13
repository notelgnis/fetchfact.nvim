# Simple fact fetcher with cashing support
A simple fact fetcher that fetches facts from the [Ninjas Facts API](https://api-ninjas.com/api/facts)
<center><img src="https://github.com/notelgnis/fetchfact.nvim/assets/36000994/4d73fa46-60a0-4931-ac50-784858ef1b49" width=80% height=80%/></center>

# Installation
## Lazy
```lua
{
    'notelgnis/fetchfact.nvim',
    dir = '~/Projects/src/personal/nvim-plugins/fetchfact.nvim',
    opts = {
        cache_file_path = '~/.cache/facts_cache.json',
        config_file_path = '~/.config/.facts_api_key',
        min_facts = 2,
        max_facts = 10,
    },
}
```
- cache_file_path: Path to the cache file where the facts are stored
- config_file_path: Path to the file where the API key is stored
- min_facts: Minimum number of facts to keep in the cache before fetching new ones
- max_facts: Maximum number of facts to keep in the cache

NOTE: Do not forget to get the API key from [Ninjas Facts API](https://api-ninjas.com/profile) and add it in the config file
# Usage Example in Dashboard
```lua
{
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
        require('dashboard').setup {
            theme = 'hyper',
            config = {
                footer = function()
                    local fact = require('fetchfact').get_fact()
                    local max_length = 90
                    local split_fact = split_long_string(fact, max_length)
                    return { '', unpack(split_fact) }
                end,
            },
        }
    end,
},
```
