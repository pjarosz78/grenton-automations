-- Funkcja pomocnicza: numer dnia w roku
local function day_of_year(year, month, day)
  local mdays = {31,28,31,30,31,30,31,31,30,31,30,31}
  if (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0) then
    mdays[2] = 29
  end
  local n = 0
  for i = 1, month - 1 do
    n = n + mdays[i]
  end
  return n + day
end

-- Obliczenie deklinacji słońca [w radianach]
local function solar_declination(N)
  return math.rad(23.45) * math.sin( 2 * math.pi * (N - 81) / 365 )
end

-- Obliczenie równania czasu (w minutach)
local function equation_of_time(N)
  local B = 2 * math.pi * (N - 81) / 365
  return 9.87 * math.sin(2 * B) - 7.53 * math.cos(B) - 1.5 * math.sin(B)
end

-- Funkcja atan2 – dla wersji Lua, która jej nie ma (choć zwykle math.atan2 istnieje)
local function atan2(y, x)
  if x > 0 then 
    return math.atan(y/x)
  elseif x < 0 and y >= 0 then 
    return math.atan(y/x) + math.pi
  elseif x < 0 and y < 0  then 
    return math.atan(y/x) - math.pi
  elseif x == 0 and y > 0 then 
    return math.pi/2
  elseif x == 0 and y < 0 then 
    return -math.pi/2
  else 
    return 0 
  end
end

-- Funkcja obliczająca elewację oraz azymut słońca.
-- Parametry:
--    year, month, day  - data (np. 2025, 6, 16)
--    hour, minute      - czas (np. 12, 0)
--    lat, lon          - współrzędne geograficzne (stopnie)
--
-- Uwaga: Dla Polski przyjmujemy stały offset = 1 (UTC+1). Aby uwzględnić czas letni należy zmienić na 2.
local function solar_position(year, month, day, hour, minute, lat, lon)
  local timezone_offset = 1  -- dla Polski zimą (UTC+1); dla DST zmień na 2.
  local N = day_of_year(year, month, day)
  local delta = solar_declination(N)         -- deklinacja [rad]
  local E = equation_of_time(N)              -- równanie czasu [min]

  -- Południk strefowy: dla UTC+1 to 15°
  local L_zone = 15 * timezone_offset
  -- Korekta czasu (w minutach): E + 4*(L_zone - longitude)
  local TC = E + 4 * (L_zone - lon)

  -- Lokalny czas słoneczny (w godzinach)
  local LST = hour + minute / 60 + TC / 60

  -- Kąt godzinowy (H) – różnica między lokalnym czasem słonecznym a południem
  local H = math.rad((LST - 12) * 15)
  local phi = math.rad(lat)

  -- Obliczenie elewacji słońca
  local sin_elev = math.sin(phi) * math.sin(delta) + math.cos(phi) * math.cos(delta) * math.cos(H)
  local elev = math.deg(math.asin(sin_elev))

  -- Obliczenie azymutu
  -- Wzór, który najpierw daje kąt mierzony od południa:
  local raw_azimuth = math.deg(atan2(math.sin(H), math.cos(H) * math.sin(phi) - math.tan(delta) * math.cos(phi)))
  -- Konwersja: dodajemy 180° i normalizujemy wynik do zakresu 0–360°,
  -- dzięki czemu azymut będzie mierzony od północy (0° = północ, 90° = wschód, 180° = południe, 270° = zachód).
  local azimuth = (raw_azimuth + 180) % 360

  return elev, azimuth
end
--------------------------------------------------

	local elevation, azimuth = solar_position(CLU01->Year, CLU01->Month, CLU01->Day, CLU01->Hour, CLU01->Minute, CLU01->Kalendarz_Zmierzch_Swit->Latitude, CLU01->Kalendarz_Zmierzch_Swit->Longitude)
	CLU01->cecha_wysokosc_slonca=elevation
	CLU01->cecha_azymut_slonca=azimuth
