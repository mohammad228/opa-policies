
# 🛡️ Terraform Security Policies with OPA & Conftest

This project provides reusable **OPA policies (written in Rego)** for analyzing **Terraform plans**, specifically targeting **AWS VPC configurations**. The goal is to prevent insecure deployments and enforce cloud security best practices.

---

## 🔍 What This Repository Does

- Audits Terraform plans (`tfplan.json`) using [Conftest](https://www.conftest.dev/)
- Implements Open Policy Agent (OPA) rules in Rego
- Prevents insecure or misconfigured AWS resources from being deployed
- Validates Terraform modules such as `terraform-aws-modules/vpc/aws`

---

## 📦 Included Policies

All policies are defined in `policy/vpc.rego`.

### ✅ 1. Disallow Insecure Public Inbound ACL Rules


### ✅ 2. Require NAT Gateway to Be Created


---

## 🧪 How to Use

### ⚙️ Prerequisites

- Terraform CLI installed
- [Conftest](https://www.conftest.dev/) installed


---

### 🧰 Usage Steps

1. **Create a Terraform plan**:

```bash
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > tfplan.json
```

2. **Run Conftest** against the generated plan:

```bash
conftest test tfplan.json --policy policy/
```

Expected output:

```bash
FAIL - tfplan.json - terraform.analysis - Public NACL rule allows all inbound traffic from 0.0.0.0/0 in resource public_inbound
FAIL - tfplan.json - terraform.analysis - No NAT Gateway is being created. Check if `enable_nat_gateway = true` is set.
```

---

## 💡 Questions & Answers

### ❓Can these policies work on other Terraform VPC codes?

Yes. These rules are written to work on **Terraform JSON plans**, regardless of the actual code, as long as they use `aws_network_acl_rule`, `aws_nat_gateway`, etc. This means you can reuse the policies across multiple projects.

---

### ❓Why do I need `tfplan.json`?

OPA and Conftest analyze **Terraform plan output**, not HCL directly. That’s why we generate a `tfplan.json`.

---

---

## 🧠 Terraform Example Setup

Here’s a simplified Terraform module using `terraform-aws-modules/vpc/aws` that your Rego rules will work with:

```hcl
module "vpc" {
  source                  = "terraform-aws-modules/vpc/aws"
  version                 = "~> 5.0"
  name                    = var.vpc_name
  cidr                    = var.vpc_cidr
  azs                     = var.availability_zones
  public_subnets          = var.public_subnets
  private_subnets         = var.private_subnets
  enable_nat_gateway      = true
  single_nat_gateway      = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  public_inbound_acl_rules  = var.public_inbound_acl_rules
  private_inbound_acl_rules = var.private_inbound_acl_rules
  tags = {
    Terraform  = "true"
    Environment = var.environment
    Project     = var.project
  }
}
```

---

## 🏗️ CI/CD Integration Example

Add this to GitHub Actions:

```yaml
- name: Terraform Plan & Test
  run: |
    terraform init
    terraform plan -out=tfplan.binary
    terraform show -json tfplan.binary > tfplan.json
    conftest test tfplan.json --policy policy/
```

---

## 📚 References

- [OPA Docs](https://www.openpolicyagent.org/docs/)
- [Conftest Docs](https://www.conftest.dev/)
- [Terraform JSON Format](https://developer.hashicorp.com/terraform/internals/json-format)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Security Hub Best Practices](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp.html)

---

## 🤝 Contribution

Feel free to submit your own `.rego` policies or open issues if you find a bug or want to contribute!

---
