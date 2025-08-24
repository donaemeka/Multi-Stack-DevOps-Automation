terraform {
  backend "s3" {
    bucket       = "donatus-terraform-state-2025"
    key          = "terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}
