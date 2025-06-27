local function replaceCronTime(cronExpression, time)
	local newHour, newMinute = time:match("^(%d%d):(%d%d)$")
    local oldMinute, oldHour, dayOfMonth, month, dayOfWeek = cronExpression:match("^(%d+) (%d+) (%S+) (%S+) (%S+)$")
    return string.format("%d %d %s %s %s", newMinute, newHour, dayOfMonth, month, dayOfWeek)
end
local function convertToCron(time)
    local hours, minutes = time:match("^(%d%d):(%d%d)$")
    return string.format("%d %d * * *", minutes, hours)
end
local function convertToTime(cron)
    local minutes, hours, dayOfMonth, month, dayOfWeek = cron:match("^(%d+) (%d+) (%S+) (%S+) (%S+)$")
    return string.format("%02d:%02d", hours, minutes)
end
local function findRule(time, rules)
	for i, rule in ipairs(rules) do
		if (convertToTime(rule[3]) == time) then
		    return rule
    	end
	end
end
local function stringToTable(s)
    local f, err = load("return " .. s)
    return f()
end
function schedulersAddRules()
	local prevSunrise, prevSunset = CLU01->cecha_poprzedni_swit_zmierzch:match("^(%S+)|(%S+)$")
	local sunriseLocal = CLU01->Kalendarz_Zmierzch_Swit->SunriseLocal
	local sunsetLocal = CLU01->Kalendarz_Zmierzch_Swit->SunsetLocal
	local newRuleId = 0
	local rules, prevRule, sRules
	--------------------------------------------------------------
	prevRule = nil
	sRules = CLU01->Harm_Oswietlenie_Elewacja->GetRules()
	if (sRules ~= nil and sRules ~= "N/A") then
		rules = stringToTable(sRules)
		prevRule = findRule(prevSunrise, rules)
	end
	if (prevRule ~= nil) then
		CLU01->Harm_Oswietlenie_Elewacja->DeleteRule(prevRule[1])
		newRuleId = CLU01->Harm_Oswietlenie_Elewacja->AddRule(replaceCronTime(prevRule[3], sunriseLocal))
		if (prevRule[2]==0 and newRuleId > 0) then
			CLU01->Harm_Oswietlenie_Elewacja->DisableRule(newRuleId)
		end
	else
		CLU01->Harm_Oswietlenie_Elewacja->AddRule(convertToCron(sunriseLocal))
	end
	--------------------------------------------------------------
	prevRule = nil
	sRules = CLU01->Harm_Oswietlenie_Elewacja_Wlacz->GetRules()
	if (sRules ~= nil and sRules ~= "N/A") then
		rules = stringToTable(sRules)
		prevRule = findRule(prevSunset, rules)
	end
	if (prevRule ~= nil) then
		CLU01->Harm_Oswietlenie_Elewacja_Wlacz->DeleteRule(prevRule[1])
		newRuleId = CLU01->Harm_Oswietlenie_Elewacja_Wlacz->AddRule(replaceCronTime(prevRule[3], sunsetLocal))
		if (prevRule[2]==0 and newRuleId > 0) then
			CLU01->Harm_Oswietlenie_Elewacja_Wlacz->DisableRule(newRuleId)
		end
	else
		CLU01->Harm_Oswietlenie_Elewacja_Wlacz->AddRule(convertToCron(sunsetLocal))
	end
	--------------------------------------------------------------
	CLU01->cecha_poprzedni_swit_zmierzch = sunriseLocal .. "|" .. sunsetLocal
end
if(typ=="schedulers_add_rules") then
	schedulersAddRules()
end
