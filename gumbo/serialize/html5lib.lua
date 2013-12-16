local util = require "gumbo.serialize.util"
local Rope = util.Rope

return function(node)
    local rope = Rope()
    local indent = "  "
    local level = 0
    local function serialize(node)
        if node.type == "element" then
            local i1, i2 = indent:rep(level), indent:rep(level+1)
            if node.tag_namespace then
                rope:appendf('| %s<%s %s>\n', i1, node.tag_namespace, node.tag)
            else
                rope:appendf('| %s<%s>\n', i1, node.tag)
            end
            local attr = node.attr
            if attr then
                table.sort(attr, function(x, y) return x.name < y.name end)
                for i = 1, #attr do
                    local a = attr[i]
                    if a.namespace then
                        rope:appendf('| %s%s %s="%s"\n', i2, a.namespace, a.name, a.value)
                    else
                        rope:appendf('| %s%s="%s"\n', i2, a.name, a.value)
                    end
                end
            end
            level = level + 1
            for i = 1, #node do
                serialize(node[i])
            end
            level = level - 1
        elseif node.type == "text" then
            rope:appendf('| %s"%s"\n', indent:rep(level), node.text)
        elseif node.type == "comment" then
            rope:appendf('| %s<!-- %s -->\n', indent:rep(level), node.text)
        elseif node.type == "document" then
            if node.has_doctype == true then
                local pubid = node.public_identifier
                local sysid = node.system_identifier
                rope:appendf('| <!DOCTYPE %s%s>\n', node.name,
                    (pubid ~= "" or sysid ~= "") and
                    string.format(' "%s" "%s"', pubid, sysid) or ""
                )
            end
            for i = 1, #node do
                serialize(node[i])
            end
        end
    end
    serialize(node)
    return rope:concat()
end
