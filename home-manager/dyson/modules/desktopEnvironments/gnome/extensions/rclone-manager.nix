{pkgs, ...}:
pkgs.gnomeExtensions.buildShellExtension {
  uuid = "rclone-manager@germanztz.com";
  name = "rclone-manager";
  pname = "rclone-manager";
  description = "Is like Dropbox sync client but for more than 30 services, adds an indicator to the top panel so you can manage the rclone profiles configured in your system, perform operations such as mount as remote, watch for file modifications, sync with remote storage, navigate it's main folder. Also, it shows the status of each profile so you can supervise the operations, and provides an easy access log of events. Backup and restore the rclone configuration file, so you won't have to configure all your devices one by one";
  link = "https://extensions.gnome.org/extension/5006/rclone-manager/";
  version = 13; # For GNOME 45
  sha256 = "eboxocuNfgQTP9omVaOSrxfpGLLO+s1vqP5PEDytJqc=";
  metadata = "ewogICJfZ2VuZXJhdGVkIjogIkdlbmVyYXRlZCBieSBTd2VldFRvb3RoLCBkbyBub3QgZWRpdCIsCiAgImRlc2NyaXB0aW9uIjogIklzIGxpa2UgRHJvcGJveCBzeW5jIGNsaWVudCBidXQgZm9yIG1vcmUgdGhhbiAzMCBzZXJ2aWNlcywgYWRkcyBhbiBpbmRpY2F0b3IgdG8gdGhlIHRvcCBwYW5lbCBzbyB5b3UgY2FuIG1hbmFnZSB0aGUgcmNsb25lIHByb2ZpbGVzIGNvbmZpZ3VyZWQgaW4geW91ciBzeXN0ZW0sIHBlcmZvcm0gb3BlcmF0aW9ucyBzdWNoIGFzIG1vdW50IGFzIHJlbW90ZSwgd2F0Y2ggZm9yIGZpbGUgbW9kaWZpY2F0aW9ucywgc3luYyB3aXRoIHJlbW90ZSBzdG9yYWdlLCBuYXZpZ2F0ZSBpdCdzIG1haW4gZm9sZGVyLiBBbHNvLCBpdCBzaG93cyB0aGUgc3RhdHVzIG9mIGVhY2ggcHJvZmlsZSBzbyB5b3UgY2FuIHN1cGVydmlzZSB0aGUgb3BlcmF0aW9ucywgYW5kIHByb3ZpZGVzIGFuIGVhc3kgYWNjZXNzIGxvZyBvZiBldmVudHMuIEJhY2t1cCBhbmQgcmVzdG9yZSB0aGUgcmNsb25lIGNvbmZpZ3VyYXRpb24gZmlsZSwgc28geW91IHdvbid0IGhhdmUgdG8gY29uZmlndXJlIGFsbCB5b3VyIGRldmljZXMgb25lIGJ5IG9uZSIsCiAgImdldHRleHQtZG9tYWluIjogInJjbG9uZS1tYW5hZ2VyIiwKICAibmFtZSI6ICJyY2xvbmUtbWFuYWdlciIsCiAgInNldHRpbmdzLXNjaGVtYSI6ICJvcmcuZ25vbWUuc2hlbGwuZXh0ZW5zaW9ucy5yY2xvbmUtbWFuYWdlciIsCiAgInNoZWxsLXZlcnNpb24iOiBbCiAgICAiNDUiCiAgXSwKICAidXJsIjogImh0dHBzOi8vZ2l0aHViLmNvbS9nZXJtYW56dHovZ25vbWUtc2hlbGwtZXh0ZW5zaW9uLXJjbG9uZS1tYW5hZ2VyIiwKICAidXVpZCI6ICJyY2xvbmUtbWFuYWdlckBnZXJtYW56dHouY29tIiwKICAidmVyc2lvbiI6IDEzCn0=";
}
