data "http" "current_ip" {
  url = "https://api.ipify.org"
}

module "orchestrate" {
  source = "./terraform"
  a = "${data.http.current_ip.response_body}/32"
}