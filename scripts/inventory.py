"""Validate inventory and build TFC root variables; never writes .tfvars."""
import csv
import ipaddress
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def build(path, environment, account, region, client_cidr, version):
    if environment not in ('dev', 'stage', 'prod'):
        raise ValueError('Invalid environment')
    if not re.fullmatch(r'\d{12}', account):
        raise ValueError('Invalid AWS account ID')
    if not re.fullmatch(r'[a-z]{2}-[a-z]+-\d', region):
        raise ValueError('Invalid AWS region')
    if not re.fullmatch(r'[A-Za-z0-9._-]{1,80}', version):
        raise ValueError('Version must be a safe artifact/commit identifier')
    if client_cidr is not None:
        network = ipaddress.ip_network(client_cidr, strict=True)
        if network.version != 4 or network.prefixlen == 0:
            raise ValueError('A restricted client IPv4 CIDR is required')
    groups = {name: {} for name in ('dev', 'stage', 'prod')}
    with open(path, newline='', encoding='utf-8-sig') as stream:
        for row in csv.DictReader(stream):
            env, key = row['environment'], row['server_key']
            if env not in groups or not re.fullmatch(r'web-01', key):
                raise ValueError('Unexpected inventory environment/server key')
            if key in groups[env]:
                raise ValueError(f'Duplicate server {env}/{key}')
            if row['app_id'] != 'APP-FLASK':
                raise ValueError('This lab accepts only APP-FLASK')
            if row['instance_type'] not in ('t2.micro',):
                raise ValueError('Unsupported lab instance type')
            size = int(row['root_disk_gib'])
            if not 8 <= size <= 30:
                raise ValueError('Root disk must be 8–30 GiB')
            groups[env][key] = {'instance_type': row['instance_type'], 'root_disk_gib': size}
    if any(len(servers) != 1 for servers in groups.values()):
        raise ValueError('Inventory must contain exactly one t2.micro server in each environment')
    return dict(aws_account_id=account, aws_region=region, environment=environment,
                app_id='APP-FLASK', app_version=version, client_cidr=client_cidr,
                vpc_cidr={'dev':'10.61.0.0/16','stage':'10.62.0.0/16','prod':'10.63.0.0/16'}[environment],
                servers=groups[environment])

