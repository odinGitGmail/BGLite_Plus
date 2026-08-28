local AddonName, ns = ...

-- 简体环境下 key 即显示文本；与 BGLite 文案体系一致
ns.L = setmetatable({}, {
    __index = function(_, key)
        return tostring(key)
    end,
})
