# More granular conditional access policies
resource "azurerm_ad_conditional_access_policy" "block_legacy_auth" {
  display_name = "Block legacy authentication protocols"
  state        = "enabled"

  conditions {
    applications {
      included_applications = ["All"]
    }

    users {
      included_users = ["All"]
    }

    client_app_types = ["exchangeActiveSync", "other"]
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]
  }
}

resource "azurerm_ad_conditional_access_policy" "high_risk_users" {
  display_name = "Require password change for high-risk users"
  state        = "enabled"

  conditions {
    applications {
      included_applications = ["All"]
    }

    users {
      included_users = ["All"]
    }

    user_risk_levels = ["high"]
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["passwordChange"]
  }
}