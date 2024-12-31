// Create a WAF Policy with managed rules and overrides for ones that do not work well with CKAN.
// Creating and applying a WAF policy is a slow process, so we use this as it's much faster than the Azure CLI.

// Rulesets:

// DRS 2.1 includes 17 rule groups, as shown in the following table.
// Each group contains multiple rules, and you can customize behavior for individual rules, rule groups, or entire rule set.
// DRS 2.1 is baselined off the Open Web Application Security Project (OWASP) Core Rule Set (CRS) 3.3.2 and includes additional proprietary protections rules developed by Microsoft Threat Intelligence team.
// https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules?tabs=owasp32#drs-21

// The Bot Manager 1.1 rule set is an enhancement to Bot Manager 1.0 rule set. It provides enhanced protection against malicious bots, and increases good bot detection.
// https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules?tabs=owasp32#bot-manager-11

// The following rules are disabled by default as they result in false positives.
// https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules?tabs=owasp32#microsoft-threat-intelligence-collection-rules

// We also disable a lot because CKAN will trigger them, these were found by logging the WAF logs and seeing what was being triggered during normal use of CKAN.
// Additional custom rules and overrides can be added to the list below if required for all Azure deployments. If a rule needs overriding for just one deployment, they can be defined in the inventory/group_vars etc as a list of lists `custom_azure_waf_rule_overrides`, the format being: [["rule-set", "rule-group-id", "rule-id"]]. These will be applied to the WAF policy synchronously after the WAF policy is created, using the CLI. THIS IS VERY SLOW so ideally keep these rules to a minimum and strongly prefer using this template to define the rules.
param frontdoorwebapplicationfirewallpolicies_wafpolicy_name string = 'wafpolicy1'

resource frontdoorwebapplicationfirewallpolicies_wafpolicy_name_resource 'Microsoft.Network/frontdoorwebapplicationfirewallpolicies@2024-02-01' = {
  name: frontdoorwebapplicationfirewallpolicies_wafpolicy_name
  location: 'Global'
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: 'Prevention'
      requestBodyCheck: 'Enabled'
      javascriptChallengeExpirationInMinutes: 30
    }
    customRules: {
      rules: []
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_DefaultRuleSet'
          ruleSetVersion: '2.1'
          ruleSetAction: 'Block'
          ruleGroupOverrides: [
            {
              ruleGroupName: 'PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920120'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
              ]
            }
            {
              ruleGroupName: 'SQLI'
              rules: [
                {
                  ruleId: '942430'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '942440'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '942120'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '942200'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '942400'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '942210'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '942410'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '942150'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '942340'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '942260'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '942330'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '942100'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '942370'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '942110'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '942140'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '942190'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '942390'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '942380'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'RFI'
              rules: [
                {
                  ruleId: '931130'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'MS-ThreatIntel-SQLI'
              rules: [
                {
                  ruleId: '99031002'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '99031003'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '99031004'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '99031001'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'PHP'
              rules: [
                {
                  ruleId: '933210'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '933160'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'General'
              rules: [
                {
                  ruleId: '200003'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '200002'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'PROTOCOL-ATTACK'
              rules: [
                {
                  ruleId: '921110'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'XSS'
              rules: [
                {
                  ruleId: '941340'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '941150'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
                {
                  ruleId: '941370'
                  enabledState: 'Disabled'
                  action: 'AnomalyScoring'
                  exclusions: []
                }
              ]
              exclusions: []
            }
          ]
          exclusions: []
        }
        {
          ruleSetType: 'Microsoft_BotManagerRuleSet'
          ruleSetVersion: '1.1'
          ruleGroupOverrides: []
          exclusions: []
        }
      ]
    }
  }
}
