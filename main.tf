data "http" "current_ip" {
  url = "https://api.ipify.org"
}

module "orchestrator" {
  source = "./terraform"
  prefix = "simple-eml"
  mediaconnect_settings = {
    mediaconnect_protocol = "srt-listener"
    whitelist_cidr_address = ["${data.http.current_ip.response_body}/32"]
    ingress_port = 5000
  }
}
