--[[----------------------------------------------------------
    gsql - Facilitate SQL programming for GmodLua

    @author Gabriel Santamaria <gaby.santamaria@outlook.fr>
------------------------------------------------------------]]
require('mysqloo') -- Based on MySQLOO module https://github.com/FredyH/MySQLOO

gsql = gsql or {
    -- [database] MYSQLOO Database object
    connection = nil,
    -- [table][PreparedQuery] Prepared queries
    prepared = {},
    -- [number] Number of affected rows in the last query
    affectedRows = nil
}

--[[----------------------------------------------------------
    gsql constructor
    Creates the new gsql object
------------------------------------------------------------]]
function gsql:new(obj, dbhost, dbname, dbuser, dbpass, port)
    obj = obj or {}
    port = port or 3306
    setmetatable(obj, self)
    -- Creating log file if doesn't already exists
    if not file.Exists('gsql_logs.txt', 'DATA') then
        file.Write('gsql_logs.txt', '')
    end
    self.__index = self
    -- Creating a new Database object
    self.connection = mysqloo.connect(dbhost, dbuser, dbpass, dbname, port)
    function self.connection.onError(err)
        error('[gsql] A fatal error appenned while connecting to the database, please check your logs for more informations!')
        file.Append('gsql_logs.txt', '[gsql][new] : ' .. err)
        return false
    end
    self.connection:connect()

    return self
end

--[[----------------------------------------------------------
    HELPER function : parse parameters in the query
    gsql.replace([string] queryStr, [table] parameters)
------------------------------------------------------------]]
function gsql.replace(queryStr, name, value)
    local pattern = '{{' .. name .. '}}'
    return string.gsub(queryStr, pattern, value)
end

--[[----------------------------------------------------------
    gsql:query([string] query, [, [table] parameters])
    Returns [table] data OR [bool] false
------------------------------------------------------------]]
function gsql:query(queryStr, parameters)
    if (queryStr == nil) then error('[gsql] Stupid ass cunt ! You call a query without giving the query itself!') end
    parameters = parameters or {}
    -- By using this instead of a table in string.gsub, we avoid nil-related errors
    for k, v in pairs(parameters) do
        v = self.connection:escape(v)
        queryStr = self.replace(queryStr, k, v)
    end
    local query = self.connection:query(queryStr) -- Doing the query
    function query:onSuccess(data)
        return data -- Simply return raw data
    end
    function query:onError(err)
        file.Append('gsql_logs.txt', '[gsql][query] : ' .. err)
        return false
    end
    query:start()
    self.affectedRows = query:affectedRows()
end

--[[----------------------------------------------------------
    Add a prepared query to the prepared queries table
    gsql:prepare([string] query)
    Returns [number] index of the prepared query
------------------------------------------------------------]]
function gsql:prepare(queryStr)
    if (queryStr == nil) then
        error('[gsql] An error occured when preparing a query!')
        file.Append('gsql_logs.txt', '[gsql][prepare] : Argument \'queryStr\' is missing. ')
    elseif (type(queryStr) ~= 'string') then
        error('[gsql] Are you stupid? An error occured when preparing a query!')
        file.Append('gsql_logs.txt', '[gsql][prepare] : Incorrect type of \'queryStr\'. querySTR, STR = STRING, you MUST give a string!')
    end
    self.prepared[#self.prepared + 1] = self.connexion:prepare(queryStr)

    return #self.prepared + 1
end

--[[----------------------------------------------------------
    Delete a prepared query from the prepared queries table
    gsql:delete([number] index)
    Returns [bool] status of deleting
------------------------------------------------------------]]
function gsql:delete(index)
    index = index or 1 -- First prepared query by default
    if (type(index) ~= 'number') then
        error('[gsql] An error occured while trying to delete a prepared query!')
        file.Append('gsql_logs.txt', '[gsql][delete] : Invalid type of \'index\'. It must be a number.')
    end
    if not self.prepared[index] then -- Checking if the index is correct
        error('[gsql] An error occured while trying to delete a prepared query! See logs for more informations')
        file.Append('gsql_logs.txt', '[gsql][delete] : Invalid \'index\'. Requested deletion of prepared query number ' .. index .. ' as failed. Prepared query doesn\'t exist')
        return false
    end
    -- Setting the PreparedQuery object to nil
    self.prepared[index] = nil
    return true
end

--[[----------------------------------------------------------
    Execute all prepared queries by their order of preparation
    Delete the executed prepared query
    gsql:execute([number] index, [table] parameters)
    Returns [table] data OR [bool] false
------------------------------------------------------------]]
function gsql:execute(index, parameters)
    parameters = parameters or {}
    local prepared = self.prepared[index]
    local i = 1
    for _, v in pairs(parameters) do
        if (type(v) == 'number') then -- Thanks Lua for the absence of a switch statement
            prepared:setNumber(i, v)
        elseif (type(v) == 'string') then
            prepared:setString(i, v)
        elseif (type(v) == 'bool') then
            prepared:setBool(i, v)
        elseif (type(v) == 'nil') then
            prepared:setNull(i)
        else
            file.Append('gsql_logs.txt', '[gsql][execute] : Invalid type of parameter (parameter : ' .. k .. ' value : ' .. v)
            error('[gsql][execute] : An error appears while preparing the query. See the logs for more informations!')
            return false
        end
        i = i + 1
    end
    function prepared:onSuccess(data)
        return data -- Simply return raw data
    end
    function prepared:onError(err)
        file.Append('gsql_logs.txt', '[gsql][execute] : ' .. err)
        return false
    end
    prepared:start()
    self.affectedRows = prepared:affectedRows()
end