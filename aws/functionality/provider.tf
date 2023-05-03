provider "aws" {
    region = var.region[0]
    shared_credentials_files = ["${path.module}/../credentials"]
    profile = "438319282780_ps-soe"
}
