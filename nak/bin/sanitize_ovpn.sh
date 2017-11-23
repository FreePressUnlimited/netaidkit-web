#!/bin/bash

filename="$1"

function ovpn_require() {
	string=$1
	grep -q "^\s*$string\s*$" $filename
	if [ $? -ne 0 ]; then
		sed -i "1 i\\$string" $filename
		echo "Added $string"
	else
		echo "$string already present skipping..."
	fi
}

function ovpn_replace() {
	match_all=$1
	match_all_line="^\s*${match_all}\s*$"
	preferred=$2
	preferred_line="^\s*${preferred}\s*$"

	grep -qe "$preferred_line" $filename
	if [ $? -ne 0 ]; then
		matched="$(grep -e "$match_all_line" $filename)"
		if [ $? -eq 0 ]; then
			sed -i "s/$match_all_line/$preferred}/" $filename
			echo "Changed \"$matched\" to \"$preferred\""
		else
			ovpn_require "$preferred"
		fi
	else
		echo "$preferred already present, skipping..."	
	fi
}

function ovpn_remove() {
	remove=$1
	remove_line="^\s*${remove}\s*$"

	matched=$(grep -e "$remove_line" $filename)
	if [ $? -eq 0 ]; then
		sed -i "/$remove_line/d" $filename
		echo "Removed $matched"
	fi
}

ovpn_replace "dev .*" "dev tun0"
ovpn_replace "user .*" "user nobody"
ovpn_replace "group .*" "group nobody"

ovpn_remove "management .*"
ovpn_remove "script-security .*"
ovpn_remove "daemon .*"

ovpn_remove "up .*"
ovpn_remove "down .*"
ovpn_remove "route-up .*"
ovpn_remove "route-pre-down .*"
ovpn_remove "client-connect .*"
ovpn_remove "learn-address .*"
ovpn_remove "auth-user-pass-verify .*"
ovpn_remove "tls-verify .*"

ovpn_require "resolv-retry infinite"
ovpn_require "nobind"
ovpn_require "client"
