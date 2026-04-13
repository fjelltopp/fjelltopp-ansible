// Create a WAF Policy for Standard SKU Front Door (custom rules only, no managed rules)
// For production with Premium SKU, managed rule sets (DRS 2.1, Bot Manager) can be added.

param frontdoorwebapplicationfirewallpolicies_wafpolicy_name string = 'wafpolicy1'

resource frontdoorwebapplicationfirewallpolicies_wafpolicy_name_resource 'Microsoft.Network/frontdoorwebapplicationfirewallpolicies@2024-02-01' = {
  name: frontdoorwebapplicationfirewallpolicies_wafpolicy_name
  location: 'Global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: 'Prevention'
      requestBodyCheck: 'Enabled'
    }
    customRules: {
      rules: []
    }
    managedRules: {
      managedRuleSets: []
    }
  }
}
