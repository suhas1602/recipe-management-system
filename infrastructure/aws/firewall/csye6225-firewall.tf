provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
}

resource "aws_cloudformation_stack" "firewall" {
  name = "wafWebapp"

  template_body = <<STACK
{
	"AWSTemplateFormatVersion": "2010-09-09",
	"Resources": {
		"Sqliset": {
			"Type": "AWS::WAFRegional::SqlInjectionMatchSet",
			"Properties": {
				"Name": "detect-sqli",
				"SqlInjectionMatchTuples": [{
						"FieldToMatch": {
							"Type": "URI"
						},
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "URI"
						},
						"TextTransformation": "HTML_ENTITY_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "QUERY_STRING"
						},
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "QUERY_STRING"
						},
						"TextTransformation": "HTML_ENTITY_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "BODY"
						},
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "BODY"
						},
						"TextTransformation": "HTML_ENTITY_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "HEADER",
							"Data": "cookie"
						},
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "HEADER",
							"Data": "cookie"
						},
						"TextTransformation": "HTML_ENTITY_DECODE"
					}
				]
			}
		},
		"SQLiRule": {
			"Type": "AWS::WAFRegional::Rule",
			"Properties": {
				"MetricName": "mitigatesqli",
				"Name": "mitigate-sqli",
				"Predicates": [{
					"Type": "SqlInjectionMatch",
					"Negated": false,
					"DataId": {
						"Ref": "Sqliset"
					}

				}]
			}
		},
		"AuthTokenStringSet": {
			"Type": "AWS::WAFRegional::ByteMatchSet",
			"Properties": {
				"Name": "match-auth-tokens",
				"ByteMatchTuples": [{
						"FieldToMatch": {
							"Type": "HEADER",
							"Data": "cookie"
						},
						"PositionalConstraint": "CONTAINS",
						"TargetString": "example-session-id",
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "HEADER",
							"Data": "authorization"
						},
						"PositionalConstraint": "ENDS_WITH",
						"TargetString": ".TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ",
						"TextTransformation": "URL_DECODE"
					}
				]
			}
		},
		"AuthTokenRule": {
			"Type": "AWS::WAFRegional::Rule",
			"Properties": {
				"MetricName": "badauthtokens",
				"Name": "detect-bad-auth-tokens",
				"Predicates": [{
					"Type": "ByteMatch",
					"Negated": false,
					"DataId": {
						"Ref": "AuthTokenStringSet"
					}

				}]
			}
		},
		"XSSSet": {
			"Type": "AWS::WAFRegional::XssMatchSet",
			"Properties": {
				"Name": "detect-xss",
				"XssMatchTuples": [{
						"FieldToMatch": {
							"Type": "URI"
						},
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "URI"
						},
						"TextTransformation": "HTML_ENTITY_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "QUERY_STRING"
						},
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "QUERY_STRING"
						},
						"TextTransformation": "HTML_ENTITY_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "BODY"
						},
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "BODY"
						},
						"TextTransformation": "HTML_ENTITY_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "HEADER",
							"Data": "cookie"
						},
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "HEADER",
							"Data": "cookie"
						},
						"TextTransformation": "HTML_ENTITY_DECODE"
					}
				]
			}
		},
		"XSSRule": {
			"Type": "AWS::WAFRegional::Rule",
			"Properties": {
				"MetricName": "mitigatexss",
				"Name": "mitigate-xss",
				"Predicates": [{
					"Type": "XssMatch",
					"Negated": false,
					"DataId": {
						"Ref": "XSSSet"
					}
				}]
			}
		},
		"PathsStringSet": {
			"Type": "AWS::WAFRegional::ByteMatchSet",
			"Properties": {
				"Name": "match-rfi-lfi-traversal",
				"ByteMatchTuples": [{
						"FieldToMatch": {
							"Type": "URI"
						},
						"PositionalConstraint": "CONTAINS",
						"TargetString": "../",
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "URI"
						},
						"PositionalConstraint": "CONTAINS",
						"TargetString": "../",
						"TextTransformation": "HTML_ENTITY_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "QUERY_STRING"
						},
						"PositionalConstraint": "CONTAINS",
						"TargetString": "../",
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "QUERY_STRING"
						},
						"PositionalConstraint": "CONTAINS",
						"TargetString": "../",
						"TextTransformation": "HTML_ENTITY_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "URI"
						},
						"PositionalConstraint": "CONTAINS",
						"TargetString": ".//",
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "URI"
						},
						"PositionalConstraint": "CONTAINS",
						"TargetString": ".//",
						"TextTransformation": "HTML_ENTITY_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "QUERY_STRING"
						},
						"PositionalConstraint": "CONTAINS",
						"TargetString": ".//",
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "QUERY_STRING"
						},
						"PositionalConstraint": "CONTAINS",
						"TargetString": ".//",
						"TextTransformation": "HTML_ENTITY_DECODE"
					}
				]
			}
		},
		"PathsRule": {
			"Type": "AWS::WAFRegional::Rule",
			"Properties": {
				"MetricName": "detectrfilfi",
				"Name": "detect-rfi-lfi-traversal",
				"Predicates": [{
					"Type": "ByteMatch",
					"Negated": false,
					"DataId": {
						"Ref": "PathsStringSet"
					}
				}]
			}
		},
		"AdminUrlStringSet": {
			"Type": "AWS::WAFRegional::ByteMatchSet",
			"Properties": {
				"Name": "match-admin-url",
				"ByteMatchTuples": [{
					"FieldToMatch": {
						"Type": "URI"
					},
					"PositionalConstraint": "STARTS_WITH",
					"TargetString": "/admin",
					"TextTransformation": "URL_DECODE"
				}]
			}
		},
		"AdminRemoteAddrIpSet": {
			"Type": "AWS::WAFRegional::IPSet",
			"Properties": {
				"Name": "match-admin-remote-ip",
				"IPSetDescriptors": [{
					"Type": "IPV4",
					"Value": "127.0.0.1/32"
				}]
			}
		},
		"AdminAccessRule": {
			"Type": "AWS::WAFRegional::Rule",
			"Properties": {
				"MetricName": "detectadminaccess",
				"Name": "detect-admin-access",
				"Predicates": [{
						"Type": "ByteMatch",
						"Negated": false,
						"DataId": {
							"Ref": "AdminUrlStringSet"
						}
					},
					{
						"Type": "IPMatch",
						"Negated": true,
						"DataId": {
							"Ref": "AdminRemoteAddrIpSet"
						}
					}
				]
			}
		},
		"PHPInsecureQSStringSet": {
			"Type": "AWS::WAFRegional::ByteMatchSet",
			"Properties": {
				"Name": "match-php-insecure-var-refs",
				"ByteMatchTuples": [{
						"FieldToMatch": {
							"Type": "QUERY_STRING"
						},
						"PositionalConstraint": "CONTAINS",
						"TargetString": "_SERVER[",
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "QUERY_STRING"
						},
						"PositionalConstraint": "CONTAINS",
						"TargetString": "_ENV[",
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "QUERY_STRING"
						},
						"PositionalConstraint": "CONTAINS",
						"TargetString": "auto_prepend_file=",
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "QUERY_STRING"
						},
						"PositionalConstraint": "CONTAINS",
						"TargetString": "auto_append_file=",
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "QUERY_STRING"
						},
						"PositionalConstraint": "CONTAINS",
						"TargetString": "allow_url_include=",
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "QUERY_STRING"
						},
						"PositionalConstraint": "CONTAINS",
						"TargetString": "disable_functions=",
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "QUERY_STRING"
						},
						"PositionalConstraint": "CONTAINS",
						"TargetString": "open_basedir=",
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "QUERY_STRING"
						},
						"PositionalConstraint": "CONTAINS",
						"TargetString": "safe_mode=",
						"TextTransformation": "URL_DECODE"
					}
				]
			}
		},
		"PHPInsecureURIStringSet": {
			"Type": "AWS::WAFRegional::ByteMatchSet",
			"Properties": {
				"Name": "match-php-insecure-uri",
				"ByteMatchTuples": [{
						"FieldToMatch": {
							"Type": "URI"
						},
						"PositionalConstraint": "ENDS_WITH",
						"TargetString": "php",
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "URI"
						},
						"PositionalConstraint": "ENDS_WITH",
						"TargetString": "/",
						"TextTransformation": "URL_DECODE"
					}
				]
			}
		},
		"PHPInsecureRule": {
			"Type": "AWS::WAFRegional::Rule",
			"Properties": {
				"MetricName": "detectphpinsecure",
				"Name": "detect-php-insecure",
				"Predicates": [{
						"Type": "ByteMatch",
						"Negated": false,
						"DataId": {
							"Ref": "PHPInsecureQSStringSet"
						}
					},
					{
						"Type": "ByteMatch",
						"Negated": false,
						"DataId": {
							"Ref": "PHPInsecureURIStringSet"
						}
					}
				]
			}
		},
		"SizeRestrictionSet": {
			"Type": "AWS::WAFRegional::SizeConstraintSet",
			"Properties": {
				"Name": "size-restrictions",
				"SizeConstraints": [{
						"FieldToMatch": {
							"Type": "URI"
						},
						"TextTransformation": "NONE",
						"ComparisonOperator": "GT",
						"Size": 512
					},
					{
						"FieldToMatch": {
							"Type": "QUERY_STRING"
						},
						"TextTransformation": "NONE",
						"ComparisonOperator": "GT",
						"Size": 1024
					},
					{
						"FieldToMatch": {
							"Type": "BODY"
						},
						"TextTransformation": "NONE",
						"ComparisonOperator": "GT",
						"Size": 102400
					},
					{
						"FieldToMatch": {
							"Type": "HEADER",
							"Data": "Cookie"
						},
						"TextTransformation": "NONE",
						"ComparisonOperator": "GT",
						"Size": 4093
					}
				]
			}
		},
		"SizeRestrictionRule": {
			"Type": "AWS::WAFRegional::Rule",
			"Properties": {
				"MetricName": "restrictsizes",
				"Name": "restrict-sizes",
				"Predicates": [{
					"Type": "SizeConstraint",
					"Negated": false,
					"DataId": {
						"Ref": "SizeRestrictionSet"
					}
				}]
			}
		},
		"ServerSideIncludeStringSet": {
			"Type": "AWS::WAFRegional::ByteMatchSet",
			"Properties": {
				"Name": "match-ssi",
				"ByteMatchTuples": [{
						"FieldToMatch": {
							"Type": "URI"
						},
						"PositionalConstraint": "STARTS_WITH",
						"TargetString": "/includes",
						"TextTransformation": "URL_DECODE"
					},
					{
						"FieldToMatch": {
							"Type": "URI"
						},
						"PositionalConstraint": "ENDS_WITH",
						"TargetString": ".cfg",
						"TextTransformation": "LOWERCASE"
					},
					{
						"FieldToMatch": {
							"Type": "URI"
						},
						"PositionalConstraint": "ENDS_WITH",
						"TargetString": ".conf",
						"TextTransformation": "LOWERCASE"
					},
					{
						"FieldToMatch": {
							"Type": "URI"
						},
						"PositionalConstraint": "ENDS_WITH",
						"TargetString": ".config",
						"TextTransformation": "LOWERCASE"
					},
					{
						"FieldToMatch": {
							"Type": "URI"
						},
						"PositionalConstraint": "ENDS_WITH",
						"TargetString": ".ini",
						"TextTransformation": "LOWERCASE"
					},
					{
						"FieldToMatch": {
							"Type": "URI"
						},
						"PositionalConstraint": "ENDS_WITH",
						"TargetString": ".log",
						"TextTransformation": "LOWERCASE"
					},
					{
						"FieldToMatch": {
							"Type": "URI"
						},
						"PositionalConstraint": "ENDS_WITH",
						"TargetString": ".bak",
						"TextTransformation": "LOWERCASE"
					},
					{
						"FieldToMatch": {
							"Type": "URI"
						},
						"PositionalConstraint": "ENDS_WITH",
						"TargetString": ".backup",
						"TextTransformation": "LOWERCASE"
					}
				]
			}
		},
		"ServerSideIncludeRule": {
			"Type": "AWS::WAFRegional::Rule",
			"Properties": {
				"MetricName": "detectssi",
				"Name": "detect-ssi",
				"Predicates": [{
					"Type": "ByteMatch",
					"Negated": false,
					"DataId": {
						"Ref": "ServerSideIncludeStringSet"
					}
				}]
			}
		},
		"BlacklistIpSet": {
			"Type": "AWS::WAFRegional::IPSet",
			"Properties": {
				"Name": "match-blacklisted-ips",
				"IPSetDescriptors": [{
						"Type": "IPV4",
						"Value": "10.0.0.0/8"
					},
					{
						"Type": "IPV4",
						"Value": "192.168.0.0/16"
					},
					{
						"Type": "IPV4",
						"Value": "169.254.0.0/16"
					},
					{
						"Type": "IPV4",
						"Value": "172.16.0.0/16"
					},
					{
						"Type": "IPV4",
						"Value": "127.0.0.1/32"
					}
				]
			}
		},
		"BlacklistIpRule": {
			"Type": "AWS::WAFRegional::Rule",
			"Properties": {
				"MetricName": "blacklistedips",
				"Name": "detect-blacklisted-ips",
				"Predicates": [{
					"Type": "IPMatch",
					"Negated": false,
					"DataId": {
						"Ref": "BlacklistIpSet"
					}
				}]
			}
		},
		"ACL": {
			"Type": "AWS::WAFRegional::WebACL",
			"Properties": {
				"MetricName": "ACL",
				"Name": "ACL",
				"DefaultAction": {
					"Type": "ALLOW"
				},
				"Rules": [{
						"Action": {
							"Type": "BLOCK"
						},
						"Priority": 10,
						"RuleId": {
							"Ref": "SizeRestrictionRule"
						}
					},
					{
						"Action": {
							"Type": "BLOCK"
						},
						"Priority": 20,
						"RuleId": {
							"Ref": "BlacklistIpRule"
						}
					},
					{
						"Action": {
							"Type": "BLOCK"
						},
						"Priority": 30,
						"RuleId": {
							"Ref": "AuthTokenRule"
						}
					},
					{
						"Action": {
							"Type": "BLOCK"
						},
						"Priority": 40,
						"RuleId": {
							"Ref": "SQLiRule"
						}
					},
					{
						"Action": {
							"Type": "BLOCK"
						},
						"Priority": 50,
						"RuleId": {
							"Ref": "XSSRule"
						}
					},
					{
						"Action": {
							"Type": "BLOCK"
						},
						"Priority": 60,
						"RuleId": {
							"Ref": "PathsRule"
						}
					},
					{
						"Action": {
							"Type": "BLOCK"
						},
						"Priority": 70,
						"RuleId": {
							"Ref": "PHPInsecureRule"
						}
					},
					{
						"Action": {
							"Type": "BLOCK"
						},
						"Priority": 80,
						"RuleId": {
							"Ref": "ServerSideIncludeRule"
						}
					},
					{
						"Action": {
							"Type": "BLOCK"
						},
						"Priority": 90,
						"RuleId": {
							"Ref": "AdminAccessRule"
						}
					}
				]

			}
		}
	}
}
STACK
}
