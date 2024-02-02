# pySigma Axon Backend

## Overview
This is the Axon backend for pySigma. It provides the package `sigma.backends.axon` with the `AxonBackend` class.
Further, it contains the following processing pipelines in `sigma.pipelines.axon`:

* axon_pipeline: Works as single pipeline to convert the possible fields into Axon Metadata Fields.

It supports the following output formats:

* default: Plain Axon Queries. You can copy and paste directly into your search bar in Axon.
* axon_api: Exports a JSON that can be used for querying AXON using its API.


## Installation
The pySigma Axon Backend is available currently only as source code and released under a whl library. 
It can be installed using pip with the command: `pip install pysigma_backend_axon-<VERSION>.whl`.

If you want to use it with sigma-cli, first validate you have it installed"
```
git clone https://github.com/SigmaHQ/sigma-cli.git
cd sigma-cli
poetry install
poetry shell
```

After copying the code of the backend, enable it in your sigma-cli with the following command: `poetry add $PATH_TO/pySigma-backend-axon`

## Usage Example
### Sigma CLI
You can quickly convert a single rule or rules in a directory structure using Sigma CLI. You can use:

`sigma convert -t axon -f default -s ~/sigma/rules` 

where -t is the target query language (axon), -f is the desired output format (default or axon_api), and -s is the Sigma rule(s) directory you wish to convert.
```
(sigma-cli-py3.9) root@a4af796c1f3f:/app/sigma-cli# sigma convert -t axon -f default ../sigma/rules/windows/network_connection/net_connection_win_ngrok_tunnel.yml 
Parsing Sigma rules  [####################################]  100%
target.host.name matches "tunnel.us.ngrok.com" OR target.host.name matches "tunnel.eu.ngrok.com" OR target.host.name matches "tunnel.ap.ngrok.com" OR target.host.name matches "tunnel.au.ngrok.com"
```

### Python Script
This example shows how to use the backend as library to be embedded inside a python script. This is using a custom class to invoke Axon API.
```
from sigma.collection import SigmaCollection
from sigma.backends.axon import axon
from siem.axon.axon_models import *
from siem.axon.axon_search import *

axon_backend = axon.axonBackend()
sigma_rule = [r"C:\sigma\rules\windows\process_creation\proc_creation_win_hktl_mimikatz_command_line.yml"]
sigma_collection = SigmaCollection.load_ruleset(sigma_rule)

api = AxonSearchAPI("API-KEY", "TENANT-ID", debug=logging.DEBUG)
for rule in sigma_collection.rules:
    json_rule = axon_backend.convert_rule(rule, "axon_api")[0]
    lr_search_request = LRSearchRequest.from_dict(json_rule)
        try:
            response = api.run_synchronous_search(lr_search_request)
            print(response)

    except AxonAPIError as e:
        print(f"API Error: {e}")
```

## Support and Maintenance
This backend is currently maintained  by:
* [Marcos Schejtman](https://github.com/natashell666/)