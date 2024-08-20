- Fix OpenRGB server
- Fix MAM IP address seeding problems (mam-dynamic-ip updates the IP address through
    the VPN, which is fine for Transmission, but then Prowlarr uses the same session
    ID without a VPN. Should I have two sessions and keep them both updated?)
- Add system-wide persist options (*especially* for home server stuff)
