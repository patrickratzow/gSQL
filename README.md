# gSQL
gSQL - Simple Query Librairy 

## What's this ?
Based on **MySQLOO**, gSQL is a simple object-oriented library designed to make effortless the use of **MySQLOO** module. The goal is that the developers only have to send the SQL queries and parameters, gSQL takes care of security and error management.

## How to use
gSQL is a very small and lightweight library. It contains only few methods which are described below.

#### Creating a new gSQL object
As we already said, **gSQL** is an object-oriented library, this means you have to work with objects instead of simple functions. You first need to create a new **gSQL** object :
```lua
local dbInfos = {
    ['dbhost'] = 'localhost',
    ['dbname'] = 'gsql',
    ['dbuser'] = 'root',
    ['dbpass'] = ''
}
-- This line create the new gSQL object, stored in our variable called "object"
local object = gsql:new(object, dbInfos['dbhost'], dbInfos['dbname'], dbInfos['dbuser'], dbInfos['dbpass'])
```
#### Doing a simple request
**gSQL**, makes SQL queries super-easy !
```lua
-- This is our query. Note that {{steamid}} is a parameter.
local queryStr = 'SELECT * FROM users WHERE steamid = {{steamid}}'
local parameters = {
    ['steamid'] = 'STEAM_0:0:0' -- Note that the key match with the name of the parameter in queryStr
}
local function callback(...)
    -- callback code, where you'll get datas, and query status
end
-- Then we can do our query
object:query(queryStr, callback, parameters)
```