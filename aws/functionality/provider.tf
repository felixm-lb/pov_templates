provider "aws" {
    region = var.region[0]
    shared_credentials_files = ["${path.module}/../credentials"]
    profile = "ACCOUNTNUMBER_ps-soe"
}
