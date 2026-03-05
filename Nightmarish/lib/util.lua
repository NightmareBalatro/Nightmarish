local M = {}

function M.deep_merge(dst, src)
  if type(src) ~= "table" then return src end
  if type(dst) ~= "table" then dst = {} end
  for k, v in pairs(src) do
    if type(v) == "table" then
      dst[k] = M.deep_merge(dst[k], v)
    else
      dst[k] = v
    end
  end
  return dst
end

function M.load(path)
  return assert(SMODS.load_file(path))()
end

function M.tonum(x, default)
  local n = tonumber(x)
  if n == nil then return default end
  return n
end

return M
