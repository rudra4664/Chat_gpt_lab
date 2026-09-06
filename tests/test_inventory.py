import csv
import io
import sys
import tempfile
import unittest
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'scripts'))
from inventory import ROOT, build

class InventoryTests(unittest.TestCase):
    def build(self, path=None, **overrides):
        args=dict(environment='dev',account='180840262641',region='us-east-1',client_cidr='192.0.2.1/32',version='test')
        args.update(overrides)
        return build(path or ROOT/'inventory/servers.csv', **args)
    def test_environment_isolation(self):
        for env in ('dev','stage','prod'):
            result=self.build(environment=env)
            self.assertEqual(len(result['servers']),1)
            self.assertEqual(result['environment'],env)
    def test_reject_world_access(self):
        with self.assertRaises(ValueError): self.build(client_cidr='0.0.0.0/0')
    def test_reject_shell_in_version(self):
        with self.assertRaises(ValueError): self.build(version='bad\nExecStart=evil')
    def test_reject_duplicate_or_partial_inventory(self):
        original=(ROOT/'inventory/servers.csv').read_text().splitlines()
        for lines in (original[:-1], original+[original[1]]):
            with tempfile.TemporaryDirectory() as directory:
                path=Path(directory)/'inventory.csv'
                path.write_text('\n'.join(lines)+'\n')
                with self.assertRaises(ValueError): self.build(path)

if __name__ == '__main__': unittest.main()

