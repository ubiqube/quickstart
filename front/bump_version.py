import argparse
import json
import yaml

VERSION = None

VERSION_FILE = "front/version.html"
HELM_CHART_FILE = "helm/Chart.yaml"
HELM_CONFIGMAP = "helm/templates/version-configmap.yaml"

def increment_version(version: str, part: str) -> str:
    """
    Increment the version number based on the specified part.

    Args:
        version (str): The current version number in the format 'major.minor.patch'.
        part (str): The part of the version to increment ('major', 'minor', or 'patch').

    Returns:
        str: The new version number after incrementing the specified part.

    Raises:
        ValueError: If the part is not one of 'major', 'minor', or 'patch'.
    """
    major, minor, patch = map(int, version.split('.'))
    if part == 'major':
        major += 1
        minor = 0
        patch = 0
    elif part == 'minor':
        minor += 1
        patch = 0
    elif part == 'patch':
        patch += 1
    return f"{major}.{minor}.{patch}"

def update_helm_chart(version: dict, chart_file: str):
    """
    Update the Chart.yaml file with the new version information.

    Args:
        version (dict): The new version information.
        chart_file (str): The path to the Chart.yaml file.
    """
    with open(chart_file) as f_chart:
        chart = yaml.safe_load(f_chart)
        full = "{}.{}".format(version['jira_version'], version['build'])
        chart['appVersion'] = full
        chart['version'] = version['msa_version']

    with open(chart_file, 'w') as f_chart:
        yaml.safe_dump(chart, f_chart, default_flow_style=False)

def update_version_configmap(version: dict, configmap_file: str):
    """
    Update the version-configmap.yaml file with the new version information.

    Args:
        version (dict): The new version information.
        configmap_file (str): The path to the version-configmap.yaml file.
    """
    with open(configmap_file) as f_configmap:
        configmap = yaml.safe_load(f_configmap)
        version_json = json.loads(configmap['data']['index.html'])
        version_json['jira_version'] = version['jira_version']
        version_json['msa_version'] = version['msa_version']
        version_json['ccla_version'] = version['ccla_version']
        version_json['build'] = version['build']
        configmap['data']['index.html'] = json.dumps(version_json, separators=(',', ':'))

    with open(configmap_file, 'w') as f_configmap:
        yaml.safe_dump(configmap, f_configmap, default_flow_style=False, sort_keys=False)

parser = argparse.ArgumentParser(description='bump version')
exclusive_group = parser.add_mutually_exclusive_group()
exclusive_group.add_argument('-u', '--update', help = 'update versions', metavar = 'json version', required = False)
exclusive_group.add_argument('-r', '--read', help = 'read versions', action = 'store_true', required = False)
exclusive_group.add_argument('-l', '--list', help = 'list files', action = 'store_true', required = False)
exclusive_group.add_argument('-p', '--part', choices=['major', 'minor', 'patch'], help='Part of the version to increment')

args = parser.parse_args()


if args.read is True:
    with open(VERSION_FILE) as f_version:
        VERSION = json.loads(f_version.read())
        print(json.dumps(VERSION))
        exit(0)

if args.list is True:
    print("{} {} {}".format(VERSION_FILE, HELM_CHART_FILE, HELM_CONFIGMAP))
    exit(0)

if args.update is not None:
    VERSION = json.loads(args.update)

#
# Update version.html
#
if VERSION is None:
    with open(VERSION_FILE) as f_version:
        VERSION = json.loads(f_version.read())
        VERSION['build'] = "{}".format(int(VERSION['build']) + 1)

if args.part is not None:
    VERSION['jira_version'] = increment_version(VERSION['jira_version'], args.part)
    VERSION['msa_version'] = increment_version(VERSION['msa_version'], args.part)
    VERSION['ccla_version'] = increment_version(VERSION['ccla_version'], args.part)
    VERSION['build'] = "0"
    print(args.part)

with open(VERSION_FILE, 'w') as f_version:
    f_version.write(json.dumps(VERSION, separators=(',', ':')))

# Call the function to update Chart.yaml
update_helm_chart(VERSION, HELM_CHART_FILE)

# Call the function to update version-configmap.yaml
update_version_configmap(VERSION, HELM_CONFIGMAP)
