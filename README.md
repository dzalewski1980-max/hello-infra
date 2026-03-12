# hello-infra


## Structure

```
package/
├── app/
│   ├── server.py
│   ├── requirements.txt
│   └── Dockerfile
├── terraform/
│   ├── providers.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── modules/
│       ├── container_app/
│       └── app_gateway/
└── .azuredevops/
    └── pipeline.yml
```

