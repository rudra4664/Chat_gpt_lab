"""Generate Terraform variable defaults, without API calls or tfvars files."""
import argparse
import hashlib
import json
from inventory import ROOT, build

def generate(check=False):
    settings=json.loads((ROOT/'inventory/settings.json').read_text())
    version=hashlib.sha256((ROOT/'app/app.py').read_bytes()+(ROOT/'app/requirements.txt').read_bytes()).hexdigest()[:16]
    for env in ('dev','stage','prod'):
        values=build(ROOT/'inventory/servers.csv',env,settings['aws_account_id'],settings['aws_region'],settings['client_cidr'],version)
        config={'variable':{k:{'default':v} for k,v in values.items()},'module':{'deployment':{'source':'../../deployments',**{k:'${var.'+k+'}' for k in values}}},'output':{k:{'value':'${module.deployment.'+k+'}'} for k in ('instances','urls')}}
        content=json.dumps(config,indent=2)+'\n'
        path=ROOT/'environments'/env/'main.tf.json'
        if check:
            if not path.exists() or path.read_text()!=content:
                raise SystemExit('Regenerate stale deployment: '+str(path))
        else:
            path.parent.mkdir(parents=True,exist_ok=True)
            path.write_text(content)
    print('Deployment defaults '+('verified' if check else 'generated'))

if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--check',action='store_true')
    generate(parser.parse_args().check)
