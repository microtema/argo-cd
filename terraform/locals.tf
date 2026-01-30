locals {
  tags = {
    Project = var.project
    Cost-Center = var.cost_center
    Environment = var.environment
    Owner = var.owner
    Department = var.department
    keep = var.environment == "prd"
    created_on = formatdate("YYYY-MM-DD", timestamp())
    creatorEmail = var.owner_email
  }

  namespace = lower("${var.project}-${var.environment}-${var.location_short}-${var.counter}")
  namespace_placeholder = lower("${var.project}-{placeholder}-${var.environment}-${var.location_short}-${var.counter}")
  namespace_trimmed = lower("${var.project}${var.environment}${var.location_short}${var.counter}")

  agent_ip = chomp(data.http.ci_agent_ip.response_body)
}