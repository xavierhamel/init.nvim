function string.starts(str, starting)
   return string.sub(str, 1, string.len(starting)) == starting
end
function string.ends(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

