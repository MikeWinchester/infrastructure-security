# NOTA: Terraform no soporta nativamente Conditional Access Policies
# Esta es una solución alternativa usando null_resource y Azure CLI

resource "null_resource" "configure_mfa_policy" {
  triggers = {
    policy_hash = md5(jsonencode({
      name    = "Require MFA for Admin Access"
      groups  = [azuread_group.admin.object_id]
    }))
  }

  provisioner "local-exec" {
    command = <<EOT
      az login --service-principal -u ${azuread_service_principal.ecommerce_sp.application_id} -p ${azuread_service_principal_password.ecommerce_sp_password.value} --tenant ${data.azurerm_client_config.current.tenant_id}
      az rest --method POST \
        --uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies" \
        --headers "Content-Type=application/json" \
        --body '{
          "displayName": "Require MFA for Admin Access",
          "state": "enabled",
          "conditions": {
            "applications": {
              "includeApplications": ["All"]
            },
            "users": {
              "includeGroups": ["${azuread_group.admin.object_id}"]
            }
          },
          "grantControls": {
            "operator": "OR",
            "builtInControls": ["mfa"]
          }
        }'
    EOT
    interpreter = ["bash", "-c"]
  }
}