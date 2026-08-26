/tablet {/ {flag=1}
flag && /map-to-output/ {
  if ($0 ~ /eDP-1/) sub("eDP-1","HDMI-A-1")
  else if ($0 ~ /HDMI-A-1/) sub("HDMI-A-1","eDP-1")
}
{print}
/}/ && flag {flag=0}
